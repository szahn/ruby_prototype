class ContactController < ApplicationController

  require 'mathutil'
  require 'userlocation'
  require 'json'
  require 'json/pure'
  require 'rubygems'
  require 'active_support/all'
  require 'logger'
  
  require 'contact_registration_response'
  require 'contact_update_response'
  require 'contact_list_response'
  require 'userlocation'
  
  MSG_UNKNOWN_ERR = -1
  MSG_OK = 0
  MSG_USER_ALREADY_EXISTS = 1
  MSG_USER_NOT_FOUND = 2
  
  def initialize()
    #@log = Logger.new('rubylog.txt')
  end

  
  def initialize
    
  end
  
  def register
    
    response = ContactRegistrationResponse.new
    response.responseCode = MSG_OK
    response.responseMsg = ""    
        
    form = ActiveSupport::JSON.decode(request.body)

    phonenum = form['UserIDStr'].to_i(16).to_s()
    lat = form['Lat']
    lon = form['Lon']    
    
    contacts = form['ContactLists']
    contactsadded = contacts['ContactsAdded']

    theuser = User.where(:phoneNumber => phonenum).first
    if theuser != nil
      response.responseMsg = "user already exists"
      response.responseCode = MSG_USER_ALREADY_EXISTS
    else
      theuser = User.create(:phoneNumber => phonenum, :lat => lat, :lon => lon)      
      response.responseMsg = "new user registered"
    end
    
    response.userHash = theuser.phoneNumber.to_i.to_s(16)
    response.userLat = theuser.lat
    response.userLon = theuser.lon
    response.userID = theuser.id
    
    response.contactsAdded = 0
      
    contactsadded.each do |contact|
      phone = contact.to_i(16).to_s()
      contact = Contact.where(:phoneNumber => phone, :user_id => theuser.id).first
      if (contact == nil)
        thecontact = Contact.new(:phoneNumber => phone)
        thecontact.user = User.where(:phoneNumber => phonenum).first
        thecontact.save
        response.contactsAdded = response.contactsAdded + 1
      end
    end    
    
    render :json => ActiveSupport::JSON.encode(response)

  end
  
  
  def update
    
    response = ContactUpdateResponse.new
    response.responseCode = MSG_OK
    response.responseMsg = ""    

    form = ActiveSupport::JSON.decode(request.body)

    phonenum = form['UserIDStr'].to_i(16).to_s()

    lat = form['Lat']
    lon = form['Lon']

    contacts = form['ContactLists']
    contactsAdded = contacts['ContactsAdded']
    contactsRemoved = contacts['ContactsRemoved']
    
    theuser = User.where(:phoneNumber => phonenum).first
    if theuser != nil

      theuser.lat = lat
      theuser.lon = lon            
      theuser.save

      response.userHash = theuser.phoneNumber.to_i.to_s(16)
      response.userLat = theuser.lat
      response.userLon = theuser.lon
      response.userID = theuser.id

      response.contactsAdded = 0
      response.contactsRemoved = 0

      contactsAdded.each do |contact|
        phone = contact.to_i(16).to_s()
        contact = Contact.where(:phoneNumber => phone, :user_id => theuser.id).first
        if (contact == nil)
          thecontact = Contact.new(:phoneNumber => phone)
          thecontact.user = User.where(:phoneNumber => phonenum).first
          thecontact.save
          response.contactsAdded = response.contactsAdded + 1
        end
      end 

      contactsRemoved.each do |contact|      
        phone = contact.to_i(16).to_s()
        contact = Contact.where(:phoneNumber => phone, :user_id => theuser.id).first
        if (contact != nil)
          Contact.delete(contact.id)
          response.contactsRemoved = response.contactsRemoved + 1
        end
      end
    
    
    else
      response.responseCode = MSG_USER_NOT_FOUND
      response.responseMsg = "User does not exist"
    end    
    
    render :json => ActiveSupport::JSON.encode(response)
    
  end
  
  
  def list

    form = ActiveSupport::JSON.decode(request.body)
    
    response = ContactListResponse.new
    response.responseCode = MSG_OK
    response.responseMsg = ""    
    response.contacts = Array.new
    
    phonenum = form['UserIDStr'].to_i(16).to_s()
    lat = form['Lat']
    lon = form['Lon']
    
    theuser = User.where(:phoneNumber => phonenum).first
    
    if (theuser != nil)
      theuser.lat = lat
      theuser.lon = lon
      theuser.save
      
      response.userHash = theuser.phoneNumber.to_i.to_s(16)
      response.userLat = theuser.lat
      response.userLon = theuser.lon
      response.userID = theuser.id
      
      contacts = Contact.where(:user_id => theuser.id);

      contacts.each do |contact|
        
        contactuser = User.where(:phoneNumber => contact.phoneNumber).first
        
        if (contactuser != nil)
          
          miles = MATHUTIL.getdistance contactuser.lat, contactuser.lon, theuser.lat, theuser.lon        
          abitem = UserLocation.new
          abitem.userID = contactuser.id
          abitem.userHash = contactuser.phoneNumber.to_i.to_s(16)
          abitem.distance_miles = miles
          abitem.lat = contactuser.lat 
          abitem.lon = contactuser.lon
                              
          response.contacts.push(abitem)
        end       
        
      end

      
    else
      response.responseCode = MSG_USER_NOT_FOUND
      response.responseMsg = "User does not exist"
    end
    

    render :json => ActiveSupport::JSON.encode(response)
    
  end

end
