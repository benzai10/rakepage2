class UserMailer < ActionMailer::Base
  default from: "rakepage@rakepage.com"
  def welcome_email
    mail(:to => "steiner.mischa@gmail.com", :subject => "Test mail", :body => "Test mail body")
  end
end
