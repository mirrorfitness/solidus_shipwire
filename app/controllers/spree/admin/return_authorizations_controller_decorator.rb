Spree::Admin::ReturnAuthorizationsController.class_eval do
  after_action :flash_message, only: [:create]

  private

  def flash_message
    message = @return_authorization.errors.messages[:shipwire]
    return unless message
    flash[:error] = message
  end
end
