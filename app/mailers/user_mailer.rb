class UserMailer < ActionMailer::Base
  default :from => UserSystem::CONFIG[:email_from].to_s

  def signup(user, password, url = nil)
    @name = user.firstname
    @login = user.login
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s

    mail(:to => user.email, :subject => "Welcome!")
  end

  def forgot_password(user, url = nil)
    @name = "#{user.firstname} #{user.lastname}"
    @login = user.login
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s

    mail(:to => user.email, :subject => "Forgotten password notification")
  end

  def change_password(user, password, url = nil)
    @name = "#{user.firstname} #{user.lastname}"
    @login = user.login
    @password = password
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s

    mail(:to => user.email, :subject => "Changed password notification")
  end

  def pending_delete(user, url = nil)
    @name = "#{user.firstname} #{user.lastname}"
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s
    @days = UserSystem::CONFIG[:delayed_delete_days].to_s

    mail(:to => user.email, :subject => "Delete user notification")
  end

  def delete(user, url=nil)
    @name = "#{user.firstname} #{user.lastname}"
    @url = url || UserSystem::CONFIG[:app_url].to_s
    @app_name = UserSystem::CONFIG[:app_name].to_s
    
    mail(:to => user.email, :subject => "Delete user notification")
  end
end
