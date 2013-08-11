require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

  has_and_belongs_to_many :shelters, :order => 'upper(name)'
  has_many :searches, :order => 'save_name'

  attr_accessor :new_password
  
  def initialize(attributes = nil)
    super
    @new_password = false
  end

  def initials
    self.class.abbrev_name(firstname, lastname)
  end

  def self.abbrev_name(fn, ln)
    fn[0..0] + ln[0..2]
  end

  def self.unverified?(login)
    find(:first, :conditions => ["login = ? AND verified = 0 AND deleted = 0", login.strip.downcase])
  end
  
  def self.authenticate(login, pass)
    u = find(:first, :conditions => ["login = ? AND verified = 1 AND deleted = 0", login.strip.downcase])
    return nil if u.nil?
    if user = find(:first, :conditions => ["login = ? AND salted_password = ? AND verified = 1", login.strip.downcase, salted_password(u.salt, hashed(pass.strip))])
		p user
      user.logged_in_at = DateTime.now.new_offset.to_s
      user.save
      return user
    end
  end

  def self.authenticate_by_token(id, token)
    # Allow logins for deleted accounts, but only via this method (and
    # not the regular authenticate call)
    u = find(:first, :conditions => ["id = ? AND security_token = ?", id, token])
    return nil if u.nil? or u.token_expired?
    return nil if false == u.update_expiry
    u
  end

  def token_expired?
    self.security_token and self.token_expiry and (Time.now > self.token_expiry)
  end

  def update_expiry
    write_attribute('token_expiry', [self.token_expiry, Time.at(Time.now.to_i + 600 * 1000)].min)
    write_attribute('authenticated_by_token', true)
    write_attribute("verified", 1)
    write_attribute("priv_read", 1)
    write_attribute("priv_new_shelters", 1)
    update_without_callbacks
  end

  def generate_security_token(hours = nil)
    if not hours.nil? or self.security_token.nil? or self.token_expiry.nil? or 
        (Time.now.to_i + token_lifetime / 2) >= self.token_expiry.to_i
      return new_security_token(hours)
    else
      return self.security_token
    end
  end

  def set_delete_after
    hours = UserSystem::CONFIG[:delayed_delete_days] * 24
    write_attribute('deleted', 1)
    write_attribute('delete_after', Time.at(Time.now.to_i + hours * 60 * 60))

    # Generate and return a token here, so that it expires at
    # the same time that the account deletion takes effect.
    return generate_security_token(hours)
  end

  def change_password(pass, confirm = nil)
    self.password = pass.strip
    self.password_confirmation = confirm.nil? ? pass : confirm.strip
    @new_password = true
  end
    
  protected

  attr_accessor :password, :password_confirmation

  def validate_password?
    @new_password
  end

  def self.hashed(str)
    return Digest::SHA1.hexdigest("change-me--#{str}--")[0..39]
  end

  after_save '@new_password = false'
  after_validation :crypt_password
  def crypt_password
    if @new_password
      write_attribute("salt", self.class.hashed("salt-#{Time.now}"))
      write_attribute("salted_password", self.class.salted_password(salt, self.class.hashed(@password.strip)))
    end
  end

  def new_security_token(hours = nil)
    write_attribute('security_token', self.class.hashed(self.salted_password + Time.now.to_i.to_s + rand.to_s))
    write_attribute('token_expiry', Time.at(Time.now.to_i + token_lifetime(hours)))
    update_without_callbacks
    return self.security_token
  end

  def token_lifetime(hours = nil)
    if hours.nil?
      UserSystem::CONFIG[:security_token_life_hours] * 60 * 60
    else
      hours * 60 * 60
    end
  end

  def self.salted_password(salt, hashed_password)
    hashed(salt + hashed_password)
  end

  def login=(str)
    write_attribute('login', str && str.strip.downcase)
  end

  validates_presence_of :login, :on => :create
  validates_format_of :login, :with => /^[a-zA-Z0-9_]+$/, :message => 'may only contain letters, numbers, and underscore (_).'
  validates_presence_of :firstname
  validates_presence_of :lastname
  validates_presence_of :email
  validates_length_of :login, :within => 3..40, :on => :create
  validates_uniqueness_of :login, :on => :create
  validates_uniqueness_of :email, :on => :create

  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  validates_length_of :password, { :minimum => 5, :if => :validate_password? }
  validates_length_of :password, { :maximum => 40, :if => :validate_password? }
end

