class StudiesController < ApplicationController
  before_action :authenticate_admin!, only: [:destroy, :destroy_all, :anayltics, :import, :answer_import, :sfa, :mail, :answer_history]
  before_action :authenticate_worker!, only: [:extraction,:direct_mail_send]
  before_action :authenticate_worker_or_user, only: [:new, :edit]
  before_action :authenticate_user_or_admin, only: [:index, :show]

  def index
    last_answer_study_ids = nil
    Rails.logger.debug("params :" + params.to_s)
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
    @q = Study.ransack(params[:q]) || study.ransack(params[:last_answer])
    @studies = @q.result || @q.result.includes(:last_answer)
    if params[:search] && params[:search][:ltec_answers_count].present?
     @studies = @studies.ltec_answers_count(params[:search][:ltec_answers_count].to_i)
    end
    @studies = @studies.where( id: last_answer ) if last_answer
    #これに変えると全抽出
    @csv_studies = @studies.distinct.preload(:answers)
    @studies = @studies.page(params[:page]).per(500) #エスクポート総数

    respond_to do |format|
     format.html
     format.csv do
        send_data @studies.generate_csv, filename: "studies-#{Time.zone.now.strftime('%Y%m%d%S')}.csv"
     end
    end
  end

  def show
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
    @study = Study.find(params[:id])
    @q = Study.ransack(params[:q]) || study.ransack(params[:last_answer])
    @studies = @q.result || @q.result.includes(:last_answer)
    @studies = @studies.where( id: last_answer )  if last_answer
    @answer = Answer.new
    @prev_study = @studies.where("studies.id < ?", @study.id).last
    @next_study = @studies.where("studies.id > ?", @study.id).first
    @is_auto_answer = (params[:is_auto_answer] == 'true')
    @user = current_user
    @worker = current_worker
  end

  def new
    @study = Study.new
  end

  def create
    @study = Study.new(study_params)
     if @study.save
       if worker_signed_in?
         redirect_to extraction_path
       else
         redirect_to study_path(id: @study.id, q: params[:q]&.permit!, last_answer: params[:last_answer]&.permit!)
       end
     else
       render 'new'
     end
  end

  def edit
    @study = Study.find(params[:id])
  end

  def update
    #@studies = study&.where(worker_id: current_worker.id)
    #@count_day = @studies.where('updated_at > ?', Time.current.beginning_of_day).where('updated_at < ?',Time.current.end_of_day).count
    @study = Study.find(params[:id])
      if @study.update(study_params)
        #if worker_sign_in?
        #  flash[:notice] = "登録が完了しました。1日あたりの残り作業実施件数は#{30 - @count_day}件です。"
        #end
        redirect_to study_path(id: @study.id, q: params[:q]&.permit!, last_answer: params[:last_answer]&.permit!)
      else
        render 'edit'
      end
  end

  def destroy
    @study = Study.find(params[:id])
    @study.destroy
    redirect_to studies_path
  end

  def destroy_all
    checked_data = params[:deletes].keys #checkデータを受け取る
    if Study.destroy(checked_data)
      redirect_to studies_path
    else
      render action: 'index'
    end
  end

  def information
    @type = params[:type]
    @answers = Answer.all
    @studies =  Study.all
    @admins = Admin.all
    @users = User.all
    case @type
    when "answer_import"
      answer_attributes = ["study_id" ,"statu", "time", "comment", "created_at","updated_at"]
      generate_answer =
        CSV.generate(headers:true) do |csv|
          csv << answer_attributes
          Answer.all.each do |task|
            csv << answer_attributes.map{|attr| task.send(attr)}
          end
        end
      respond_to do |format|
        format.html
        format.csv{ send_data generate_answer, filename: "answers-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
      end
    when "update_import"
      respond_to do |format|
       format.html
       format.csv{ send_data @studies.generate_csv, filename: "studies-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
      end
    else
   end
  end

  def news
    @studies = Study.all
  end

  def import
    cnt = Study.import(params[:file])
    redirect_to studies_url, notice:"#{cnt}件登録されました。"
  end

  def answer_import
    cnt = Answer.answer_import(params[:answer_file])
    redirect_to studies_url, notice:"#{cnt}件登録されました。"
  end

  private
    def study_params
      params.require(:study).permit(
        :question,
        :genre,
        :kategory,
        :year,
        :answer
       )&.merge(worker: current_worker)
    end

    def authenticate_user_or_admin
      unless user_signed_in? || admin_signed_in?
         redirect_to new_user_session_path, alert: 'error'
      end
    end

    def authenticate_worker_or_admin
      unless worker_signed_in? || admin_signed_in?
         redirect_to new_worker_session_path, alert: 'error'
      end
    end

    def authenticate_worker_or_user
      unless user_signed_in? ||  worker_signed_in?
         redirect_to new_worker_session_path, alert: 'error'
      end
    end

end
