require 'scraping'
class Study < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :worker, optional: true
  has_many :estimates
  has_many :answers
  has_many :counts
  has_one :last_answer, ->{
    order("created_at desc")
  }, class_name: :answer

#study_import
  def self.import(file)
      save_cont = 0
      CSV.foreach(file.path, headers:true) do |row|
       study = find_by(id: row["id"]) || new
       study.attributes = row.to_hash.slice(*updatable_attributes)
       next if study.industry == nil
       next if self.where(tel: study.tel).where(industry: nil).count > 0
       next if self.where(tel: study.tel).where(industry: study.industry).count > 0
       study.save!
       save_cont += 1
      end
      save_cont
  end
  def self.updatable_attributes
    ["id","company","tel","address","url","url_2","title","industry","mail","first_name","postnumber","people",
     "caption","business","genre","mobile","choice","inflow","other","history","area","target","meeting","experience","price",
     "number","start","remarks","extraction_count","send_count"]
  end

  #update_import
  def self.update_import(update_file)
    save_cnt = 0
    CSV.foreach(update_file.path, headers: true) do |row|
      study = find_by(id: row["id"]) || new
      study.attributes = row.to_hash.slice(*updatable_attributes)
      study.save!
      save_cnt += 1
    end
    save_cnt
  end

#tcare_import
  def self.tcare_import(tcare_file)
      save_cont = 0
      CSV.foreach(tcare_file.path, headers:true) do |row|
       study = find_by(id: row["id"]) || new
       study.attributes = row.to_hash.slice(*updatable_attributes)
       next if study.industry == nil
       #next if self.where(company: study.company).where(industry: nil).count > 0
       #next if self.where(company: study.company).where(industry: study.industry).count > 0
       study.save!
       save_cont += 1
      end
      save_cont
  end



#study_export
  def self.generate_csv
    CSV.generate(headers:true) do |csv|
      csv << csv_attributes
      all.each do |task|
        csv << csv_attributes.map{|attr| task.send(attr)}
      end
    end
  end
  def self.csv_attributes
    ["id","company","tel","address","url","url_2","title","industry","mail","first_name","postnumber","people",
     "caption","business","genre","mobile","choice","inflow","other","history","area","target","meeting","experience","price",
     "number","start","remarks","extraction_count","send_count"]
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:answers_count_lt]
  end

  def self.answers_count_lt(count)
    select('*, COUNT(answers.id) AS answers_count')
    .joins(:answers)
    .group('studies.id')
    .where('answers_count <= ?', count)
  end

  @@ChoiceItems = [
    [1,"SORAIRO関東"],
    [2,"SORAIRO九州"],
    [3,"ティンロンジャパン"],
    [4,"アイアットOEC"]
  ]
  def self.ChoiceItems
    @@ChoiceItems
  end

  @@old_status = [
    [0,"不在"],
    [1,"担当者不在"],
    [2,"見込"],
    [3,"折返待"],
    ["app","APP"],
    ["ng_now","今は結構"],
    ["ng_foreign","外国人NG"],
    ["ng_front","フロントNG"]
  ]
  def self.Old_status
    @@old_status
  end

  @@business_status = [
    ["人材関連業","人材関連業"],
    ["広告業","広告業"],
    ["マーケ・コンサルティング業","マーケ・コンサルティング業"],
    ["飲食店","飲食店"],
  ]
  def self.BusinessStatus
    @@business_status
  end

  @@genre_status = [
    ["人材関連業","人材関連業"],
    ["┗人材派遣","┗人材派遣"],
    ["┗人材紹介","┗人材紹介"],
  ]
  def self.GenreStatus
    @@genre_status
  end

  @@extraction_status = [
    ["リスト抽出不可","リスト抽出不可"]
  ]
  def self.ExtractionStatus
    @@extraction_status
  end

  @@send_status = [
    ["メール送信済","メール送信済"]
  ]
  def self.SendStatus
    @@send_status
  end

  enum status: {draft: 0, published: 1}

  def get_search_url
    unless @contact_url
      @contact_url =
        scraping.contact_from(url_2) ||
        scraping.contact_from(url) ||
        scraping.contact_from(
          scraping.google_search([company, address, tel].compact.join(' '))
        )
    end
    @contact_url
  end

  def google_search_url
    scraping.google_search([company, address, tel].compact.join(' '))
  end

  def get_url_arry
    url_arry = []
    url_arry.push(url) if url.present?
    url_arry.push(url_2) if url_2.present?

    url_arry
  end

  private

  def scraping
    @scraping ||= Scraping.new
  end
end
