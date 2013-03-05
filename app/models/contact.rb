class Contact < ActiveRecord::Base
  
  attr_accessible :phoneNumber, :user_id
  belongs_to :user, :foreign_key => "user_id"
  
end
