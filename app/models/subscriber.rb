class Subscriber < ApplicationRecord
  # associations
  belongs_to :user, optional: true

  # tokens
  generates_token_for :confirm
  generates_token_for :view_newsletter
  generates_token_for :invitation

  # validation
  validates :email_address, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP

  # scopes and queries
  scope :not_users, -> { where.missing(:user) }
  filter_scope :artist, ->(value) { where(artist: ActiveModel::Type::Boolean.new.cast(value)) }
  filter_scope :confirmed, ->(value) { where(confirmed: ActiveModel::Type::Boolean.new.cast(value)) }

  # class methods
  def self.filter(by)
    case by
    when "artists"
      Subscriber.order(created_at: "desc").where(artist: true)
    when "confirmed"
      Subscriber.order(created_at: "desc").where(confirmed: true)
    when "unconfirmed"
      Subscriber.order(created_at: "desc").where(confirmed: false)
    else
      Subscriber.order(created_at: "desc").all
    end
  end

  # instance methods
  def invite
    unless self.confirmed
      self.errors.add :last_invited, "Cannot send any emails to a subscriber when they haven't confirmed."
      return false
    end

    self.update(last_invited: DateTime.current)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def signed_up_at
    days_since = ((DateTime.current.to_time - created_at.to_time)/(24*60*60)).round.to_i
    case days_since
    when 0
      "today"
    when 1..6
      "#{days_since} days ago"
    when 7..13
      "a week ago"
    when 14..20
      "2 weeks ago"
    else
      created_at.strftime("%d/%m/%y")
    end
  end
end
