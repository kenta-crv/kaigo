class InformationAnalyticForm
  include ActiveModel::Model

  INDUSTRY_KEYS = [
    'SORAIRO',
    'サンズ',
    'asia（介護）',
    'asia（食品加工）',
    '圏友（介護）',
    '圏友（食品加工）',
    'さくら（介護）',
    'さくら（食品加工）',
  ]

  attr_accessor :user_id, :year, :month

  def call_count
    industries.sum(&:call_count)
  end

  def appointment_rate
    return 0 if call_count <= 0

    appointment_count * 100.0 / call_count
  end

  def appointment_count
    industries.sum(&:appointment_count)
  end

  def sales
    industries.sum(&:sales)
  end

  def incentive_total
    industries.sum(&:incentive_total)
  end

  def industries
    unless @industries
      @industries = INDUSTRY_KEYS.map do |industry_key|
        IndustryAnalytics.new(
          key: industry_key,
          user_id: user_id,
          year: year,
          month: month
        )
      end
    end
    @industries
  end

  def users
    @users ||= User.all
  end

  def selected_user
    return nil unless user_id

    @selected_user ||= User.find(user_id)
  end

  def link_to_queries(key = nil)
    next_month = Date.new(year.to_i, month.to_i, 1) + 1.month

    queries = {
      last_call: {
        created_at_from: "#{year}-#{month}-01",
        created_at_to: "#{next_month.year}-#{next_month.month}-01",
      },
      q: {
        statu: 'APP'
      },
    }

    queries[:q][:industry_cont] = key if key

    queries[:q][:calls_user_user_name_cont] = selected_user.user_name if selected_user

    queries
  end
end
