class User < ActiveRecord::Base

  attr_accessible :lat, :lon, :phoneNumber
  has_many  :contacts, :foreign_key => "user_id"
  self.primary_key = "id"
  
   def to_json(*a, msg)
    {
      'response'   => msg,
      'phoneNumber'   => phoneNumber,
      'lat'   => lat,
      'lon'   => lon
    }.to_json(*a)
  end

end
