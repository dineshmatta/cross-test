##

# module to recognize bounced mails based on some simple rules
module BounceHelper
  def bounced?(mail)
    return true if mail.bounced?
    return true if !mail.header['Return-Path'].nil? && mail['Return-Path'].value == ''

    false
  end
end
