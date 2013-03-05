class ContactRegistrationResponse
  require 'json'
  require 'json/pure'
    
  attr_accessor :contactsAdded, :userID, :userHash, :userLat, :userLon, :responseMsg, :responseCode
  
  def initialize
    
  end
  
end
