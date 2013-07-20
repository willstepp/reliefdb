class UserNotify < ActionMailer::Base
  def signup(user, password, url=nil)
    setup_email(user, "Welcome!")
    body    :name => user.firstname,
            :login => user.login,
            :url => url || UserSystem::CONFIG[:app_url].to_s,
            :app_name => UserSystem::CONFIG[:app_name].to_s
  end

  def forgot_password(user, url=nil)
    setup_email(user,"Forgotten password notification")
    body    :name => "#{user.firstname} #{user.lastname}",
            :login => user.login,
            :url => url || UserSystem::CONFIG[:app_url].to_s,
            :app_name => UserSystem::CONFIG[:app_name].to_s
  end

  def change_password(user, password, url=nil)
    setup_email(user, "Changed password notification")
    body    :name => "#{user.firstname} #{user.lastname}",
            :login => user.login,
            :password => password,
            :url => url || UserSystem::CONFIG[:app_url].to_s,
            :app_name => UserSystem::CONFIG[:app_name].to_s
  end

  def pending_delete(user, url=nil)
    setup_email(user,"Delete user notification")
    body    :name => "#{user.firstname} #{user.lastname}",
            :url => url || UserSystem::CONFIG[:app_url].to_s,
            :app_name => UserSystem::CONFIG[:app_name].to_s,
            :days => UserSystem::CONFIG[:delayed_delete_days].to_s
  end

  def delete(user, url=nil)
    setup_email(user,"Delete user notification")
    body    :name => "#{user.firstname} #{user.lastname}",
            :url => url || UserSystem::CONFIG[:app_url].to_s,
            :app_name => UserSystem::CONFIG[:app_name].to_s
  end

  def setup_email(user, subject)
    recipients  user.email
    from        UserSystem::CONFIG[:email_from].to_s
    subject     UserSystem::CONFIG[:app_name] + ":" + subject
    sent_on     Time.now
#    headers['Content-Type'] = "text/plain; charset=#{UserSystem::CONFIG[:mail_charset]}; format=flowed"
  end
end
