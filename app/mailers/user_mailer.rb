class UserMailer < ActionMailer::Base
  default from: "rakepage@rakepage.com"
  def welcome_email
    mail(to: "steiner.mischa@gmail.com",
         subject: "Test mail",
         template_path: "user_mailer",
         template_name: "welcome_email")
  end
end
