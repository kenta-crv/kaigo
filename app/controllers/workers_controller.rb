class WorkersController < ApplicationController
  def show
    @worker = Worker.find(params[:id])
    @studies = study&.where(worker_id: current_worker.id)
    @count_day = @studies.where('updated_at > ?', Time.current.beginning_of_day).where('updated_at < ?',Time.current.end_of_day).count
    @count_week = @studies.where('updated_at > ?', Time.current.beginning_of_week).where('updated_at < ?',Time.current.end_of_week).count
    @count_month = @studies.where('updated_at > ?', Time.current.beginning_of_month).where('updated_at < ?',Time.current.end_of_month).count

    @contact_trackings_month = @worker.contact_trackings.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
    @contact_trackings_before_month = @worker.contact_trackings.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    @contact_trackings_day = @worker.contact_trackings.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
    @contact_trackings_week = @worker.contact_trackings.where(created_at: Time.current.beginning_of_week..Time.current.end_of_week)

    @send_success_count_day = @contact_trackings_day.where(status: '送信済').count.to_i
    @send_success_count_week = @contact_trackings_week.where(status: '送信済').count.to_i
    @send_success_count_month = @contact_trackings_month.where(status: '送信済').count.to_i
    @send_success_count_before_month = @contact_trackings_before_month.where(status: '送信済').count.to_i

    @send_error_count_month = @contact_trackings_month.where(status: '送信不可').count.to_i
    @send_ng_count_month = @contact_trackings_month.where(status: '営業NG').count.to_i
    @send_count_month = @send_success_count_month + @send_error_count_month + @send_ng_count_month
    if @send_count_month > 0
      @send_rate = @send_success_count_month / @send_count_month.to_f * 100
    end

    @send_count_day = @contact_trackings_day.count

    @send_count_week = @contact_trackings_week.count
  end
end
