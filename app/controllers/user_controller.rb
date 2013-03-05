class UserController < ApplicationController
  
  require 'mathutil'
  require 'userlocation'
  require 'json'
  require 'json/pure'
  require 'rubygems'
  require 'active_support/all'
  require 'logger'
  
  require 'user_verify_response'
  
  MSG_UNKNOWN_ERR = -1
  MSG_OK = 0

  def verify
    response = UserVerifyResponse.new
    response.responseCode = MSG_OK
    response.responseMsg = ""    

    form = ActiveSupport::JSON.decode(request.body)
    phonenum = form['UserIDStr'].to_i(16).to_s()

    response.verifyCode = "123456"
    
    sms = Moonshado::Sms.new(phonenum, 
      "mRadius Verification Code:" + response.verifyCode)

    response.responseMsg = sms.deliver_sms

    render :json => ActiveSupport::JSON.encode(response)
    
  end
  
end
