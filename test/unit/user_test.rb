require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  
  fixtures :users
    
  def test_auth
    
    assert_equal  @bob, User.authenticate("bob", "atest")    
    assert_nil User.authenticate("nonbob", "atest")
    
  end


  def test_passwordchange
        
    @longbob.change_password("nonbobpasswd")
    @longbob.save
    assert_equal @longbob, User.authenticate("longbob", "nonbobpasswd")
    assert_nil User.authenticate("longbob", "alongtest")
    @longbob.change_password("alongtest")
    @longbob.save
    assert_equal @longbob, User.authenticate("longbob", "alongtest")
    assert_nil User.authenticate("longbob", "nonbobpasswd")
        
  end
  
  def test_disallowed_passwords
    
    u = User.new    
    u.login = "nonbob"

    u.change_password("tiny")
    assert !u.save     
    assert u.errors.invalid?('password')

    u.change_password("hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge")
    assert !u.save     
    assert u.errors.invalid?('password')
        
    u.change_password("")
    assert !u.save    
    assert u.errors.invalid?('password')
        
    u.change_password("bobs_secure_password")
    assert u.save     
    assert u.errors.empty?
        
  end
  
  def test_bad_logins

    u = User.new  
    u.change_password("bobs_secure_password")

    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?('login')
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
      
  end


  def test_collision
    u = User.new
    u.login = "existingbob"
    u.change_password("bobs_secure_password")
    assert !u.save
  end


  def test_create
    u = User.new
    u.login = "nonexistingbob"
    u.change_password("bobs_secure_password")
      
    assert u.save  
    
  end
  
end
