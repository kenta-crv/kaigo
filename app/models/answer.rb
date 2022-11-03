class Answer < ApplicationRecord
  belongs_to :study#, foreign_key: :tel, primary_key: :tel
  belongs_to :admin, optional: true
  belongs_to :user, optional: true
  scope :times_last_answer, -> {
    last_time = "SELECT sub_answer.study_id, MAX(sub_answer.time) as last_time FROM answers as sub_answer GROUP BY sub_answer.study_id";
    joins(
      "INNER JOIN (#{last_time}) AS sub ON sub.study_id = answers.study_id AND sub.last_time = answers.time"
    ).group(:study_id)
  }

  scope :joins_last_answer, -> {
    last_created_at = "SELECT sub_answer.study_id, MAX(sub_answer.created_at) as last_created_at FROM answers as sub_answer GROUP BY sub_answer.study_id";
    joins(
      "INNER JOIN (#{last_created_at}) AS sub ON sub.study_id = answers.study_id AND sub.last_created_at = answers.created_at"
    ).group(:study_id)
  }

  scope :last_answer_notification, ->(sender_id){
    includes(study: :contact_trackings).where(contact_trackings: { id: ContactTracking.latest(sender_id).select(:id) })
  }

  scope :answer_count_today, -> {
    where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
  }

  scope :answer_count_hour, -> {
    where(created_at: Time.current.beginning_of_hour..Time.current.end_of_hour)
  }

  # 本日獲得見込数
  scope :protect_count_today, -> {
    answer_count_today.where(statu: "見込")
  }

  # 本日アポ数
  scope :app_count_today, -> {
    answer_count_today.where(statu: "APP")
  }

  scope :unread_notification, -> {
    where.not(time: nil)
      .where('latest_confirmed_time is null or time >= latest_confirmed_time')
  }

  scope :between_created_at, ->(from, to){
    where(created_at: from..to)
  }

  #answer_import
    def  self.answer_import(answer_file)
      save_cnt = 0
      CSV.foreach(answer_file.path, headers: true) do |row|
        answer = answer.find_by(id: row["id"]) || new
        study = study.find_by(tel: row["tel"])
        answer.attributes = row.to_hash.slice(*answer_attributes)
        answer.study_id = study&.id
        #直近１ヶ月以内にanswerをcreated_atしていない
        next if self.where(study_id: answer.study.id).where("created_at > ?", Time.now - 2.month).count > 0
        lastRecords = self.where(study_id: answer.study.id).order(created_at: :desc).limit(1)
        if !lastRecords.empty?
            lastRecord = lastRecords.first()
            next if ['APP', '永久NG', '根本的NG'].include?(lastRecord.statu)
        elsif answer.id == nil
          next if self.where(id: answer.id).count == 0
        end
        #answerの最新のものでみる
        answer.save!
        save_cnt += 1
      end
      save_cnt
    end

    def self.answer_attributes
      ["study" ,"statu", "time", "comment", "created_at","updated_at"]
    end

  @@StatuItems = [
    "着信留守",
    "担当者不在",
    "フロントNG",
    "見込",
    "APP",
    "APPキャンセル",
    "NG",
    "クロージングNG",
    "永久NG",
    "契約",
    "再掲載",
    "未提案",
    "再コール",
    "見積中",
    "見込高",
    "見込中",
    "見込低",
    "再APP"
  ]
  def self.StatuItems
    @@StatuItems
  end

  @@sfa_status = [
    ["未提案","未提案"],
    ["再コール","再コール"],
    ["再APP","再APP"],
    ["見積中","見積中"],
    ["見込高","見込高"],
    ["見込中","見込中"],
    ["見込低","見込低"],
    ["契約","契約"],
    ["予算感NG","予算感NG"],
    ["時期NG","時期NG"],
    ["NG","NG"],
    ["永久NG","永久NG"],
    ["契約終了","契約終了"],
    ["Comicomi案件","Comicomi案件"]
  ]
  def self.SfaStatus
    @@sfa_status
  end

  # 見込数
  def self.protect_convertion
    (answer.protect_count_today.count.to_f / answer.answer_count_today.count.to_f) * 100
  end

  # アポ率
  def self.app_convertion
    (answer.app_count_today.count.to_f / answer.answer_count_today.count.to_f) * 100
  end

  # 活動中ユーザ数
  def self.active_user_count
    answer.answer_count_today.group(:user_id).having('count(*) > 0').count.count
  end

  def date_count
    answer.group("DATE_FORMAT(created_at, '%Y-%m-%d')").count
  end

  def week_count
    answer.group("WEEK(created_at)").count
  end

  def month_count
    answer.group("MONTH(created_at)").count
  end

  def user_time_count #時間単位のカウント
    answer.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
  end

  #def user_app
  #  U
  #end

end
