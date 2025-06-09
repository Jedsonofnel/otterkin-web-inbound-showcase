class SubscribersController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: [ :create ], with: -> { redirect_to root_path, alert: "Try again later." }

  def new
    @subscriber = Subscriber.new()
  end

  def create
    # bot catching
    submitted_at = Time.current.to_i
    loaded_at = params[:form_loaded_at].to_i

    if params[:nickname].present? || (submitted_at - loaded_at) < 3
      head :ok
      return
    end

    @subscriber = Subscriber.new(subscriber_params)

    if @subscriber.save
      SubscriberMailer.with(subscriber: @subscriber).welcome.deliver_later
      render "subscribers/thanks"
    else
      render :new
    end
  end

  def confirm
    if @subscriber = Subscriber.find_by_token_for(:confirm, params[:token])
      @subscriber.update(confirmed: true)
    else
      redirect_to root_path, alert: "That confirm link is invalid, please try again."
    end
  end

  private

  def subscriber_params
    params.expect(subscriber: [ :first_name, :last_name, :email_address, :artist, :instagram_handle, :introduction ])
  end
end
