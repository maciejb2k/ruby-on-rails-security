class PhishingController < ApplicationController
  def fake_login
  end

  def steal_credentials
    Rails.logger.info "Użytkownik próbował zalogować się na fałszywej stronie: #{params[:email]} / #{params[:password]}"
    render plain: 'Twoje dane zostały skradzione! (na potrzeby symulacji, nie faktycznie)'
  end
end
