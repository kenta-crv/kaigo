class AnswersController < ApplicationController
  before_action :load_study
  before_action :load_answer, only: [:edit,:update,:show,:destroy]
  #before_action :authenticate_admin!

  def load_study
    last_answer_study_ids = nil
    @last_answer_params = {}
    if params[:last_answer] && !params[:last_answer].values.all?(&:blank?)
      @last_answer_params = params[:last_answer]
      last_answer = answer.joins_last_answer.select(:study_id)
      last_answer = last_answer.where(statu: @last_answer_params[:statu]) if !@last_answer_params[:statu].blank?
      last_answer = last_answer.where("answers.time >= ?", @last_answer_params[:time_from]) if !@last_answer_params[:time_from].blank?
      last_answer = last_answer.where("answers.time <= ?", @last_answer_params[:time_to]) if !@last_answer_params[:time_to].blank?
      last_answer = last_answer.where("answers.created_at >= ?", @last_answer_params[:created_at_from]) if !@last_answer_params[:created_at_from].blank?
      last_answer = last_answer.where("answers.created_at <= ?", @last_answer_params[:created_at_to]) if !@last_answer_params[:created_at_to].blank?
    end
    @study = study.find(params[:study_id])
    @answer = Answer.new
    @q = study.ransack(params[:q]) || study.ransack(params[:last_answer])
    @studies = @q.result || @q.result.includes(:last_answer)
    @studies = @studies.where( id: last_answer )  if last_answer
    @next_study = @studies.where("studies.id > ?", @study.id).first
    @is_auto_answer = (params[:is_auto_answer] == 'true')
  end

  def load_answer
    @answer = Answer.find(params[:id])
  end

  def edit
  end

  def create
    @answer = @study.answers.new(answer_params)
      if @study.answers.count >= 3
        # 最新のステータスが着信留守3回連続の場合、4回目は永久NGとする
        if @study.answers.order(created_at: :asc).limit(4).pluck(:statu).all? { |w| w == "着信留守"  }
          if @answer.statu == "着信留守"
            @answer.statu = "永久NG"
            @answer.save
          end
        elsif @study.answers.order(created_at: :desc).limit(4).pluck(:statu).all? { |w| w == "担当者不在"  }
          if @answer.statu == "担当者不在"
            @answer.statu = "永久NG"
            @answer.save
          end
        end
      end
      @answer.save

      if @next_study
        redirect_to study_path(
          id: @next_study.id,
          q: params[:q]&.permit!,
          last_answer: params[:last_answer]&.permit!
        )
      else
        redirect_to request.referer, notice: 'リスト が終了しました。再度検索し架電を進めてください。'
      end
  end

  def update
    if @answer.update(answer_params)
      redirect_to study_path(id: @study.id, q: params[:q]&.permit!, last_answer: params[:last_answer]&.permit!)
    else
      render 'edit'
    end
  end

  def destroy
    @study = study.find(params[:study_id])
    @answer = @study.answers.find(params[:id])
    @answer.destroy
    redirect_to study_path(id: @study.id, q: params[:q]&.permit!)
  end

  private
 	def answer_params
 		params.require(:answer).permit(
 		:statu, #ステータス
    :sfa_statu,
 		:time, #再コール
 		:comment, #コメント
    :tel,
    :item_select => []
    )&.merge(admin: current_admin)
     &.merge(user: current_user)
 	end
end
