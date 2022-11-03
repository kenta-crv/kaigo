class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource


  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500
    render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_name, :select])
  end

    # set for devise login redirector
    def after_sign_in_path_for(resource)
      case resource
      when Admin
         studies_path
      when User
         studies_path
      when Worker
        worker_path(current_worker)
      when Sender
        if current_sender.inquiries.empty?
          flash[:notice] = "案件の内容を登録してください"

          new_sender_inquiry_path(current_sender)
        else
          myself_path
        end
      when Client
        client_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      case resource
      when Admin, :admin, :admins
        new_admin_session_path
      when User, :user, :users
        new_user_session_path
      when Worker, :worker, :workers
        new_worker_session_path
      when Sender, :sender, :senders
        new_sender_session_path
      when Client, :client, :clients
        new_sender_client_path
      else
        super
      end
    end

  # Layout per resource_name
  # TODO: `layout_by_resource` メソッドがかぶっているので、このメソッドは不要に見える。不要なら消す。
  def layout_by_resource
    if devise_controller? && resource_name == :admin
        "admins"
    elsif devise_controller? && resource_name == :user
        "users"
    elsif devise_controller? && resource_name == :worker
        "workers"
    elsif devise_controller? && resource_name == :sender
        "senders"
    else
      "application"
    end
  end

  def layout_by_resource
    if devise_controller?
      "application"
    end
  end

  #before_action :authenticate_user_or_admin"

  #private
  #  def authenticate_user_or_admin
  #    unless user_signed_in? || admin_signed_in?
  #       redirect_to root_path, alert: 'error'
  #    end
  #  end

end
