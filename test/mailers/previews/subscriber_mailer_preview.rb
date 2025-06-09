# Preview all emails at http://localhost:3000/rails/mailers/subscriber_mailer
class SubscriberMailerPreview < ActionMailer::Preview
  def welcome
    SubscriberMailer.with(subscriber: Subscriber.first).welcome
  end

  def notify_newsletter
    SubscriberMailer.with(
      subscriber: Subscriber.first,
      newsletter: Article.where(published: true, designation: "newsletter").last.newsletter
    ).notify_newsletter
  end
end
