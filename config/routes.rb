Rails.application.routes.draw do
  root to: 'top#index'
  get 'usp' => 'top#usp'
  get 'question' => 'top#question'
  get 'co' => 'top#co'

  #管理者アカウント
  devise_for :admins, controllers: {
    registrations: 'admins/registrations'
  }
  resources :admins, only: [:show]
  #ユーザーアカウント
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :users, only: [:show]
  #ワーカーアカウント
  devise_for :workers, controllers: {
    registrations: 'workers/registrations',
    sessions: 'workers/sessions',
    confirmations: 'workers/confirmations',
    passwords: 'workers/passwords',
  }
  resources :workers, only: [:show]


  resources :studies do
    resources :answers
    resources :counts
    member do
      get :contact
      post :send_mail
    end
    collection do
      get :complete
      post :thanks
      post :import
      post :update_import
      post :answer_import
      post :tcare_import
      get :message
      get :bulk_destroy
    end
  end

  get 'list' => 'studies#list'
  get 'studies/:id/:is_auto_answer' => 'studies#show'
  get 'direct_mail_send/:id' => 'studies#direct_mail_send' #SFA
  #get 'sender/:id/' => 'sender#show'
  scope :information do
    get '' => 'studies#information', as: :information #分析

    resource :incentive, only: [:show, :update], path: '/incentives/:year/:month'
  end

  get 'news' => 'studies#news' #インポート情報
  get 'answer_history'=> 'studies#answer_history' #インポート情報
  get 'export' => 'studies#export' #
  get 'sfa' => 'studies#sfa' #SFA

  #post 'studies/contact' => 'studies#contact' #メール送信
  #post 'studies/thanks' => 'ustomers#thanks' #メール送信完了
  get 'extraction' => 'studies#extraction' #TCARE
  delete :studies, to: 'studies#destroy_all' #Mailer

  #お問い合わせフォーム
  get 'contact' => 'contact#index'
  post 'contact/confirm' => 'contact#confirm'
  post 'contact/thanks' => 'contact#thanks'

  # API
  namespace :api do
    namespace :v1 do
      resources :smartphones
      namespace :smartphone_logs do
        post '/' , :action => 'create'
      end
    end
  end

  get '*path', controller: 'application', action: 'render_404'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
