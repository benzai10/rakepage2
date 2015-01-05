class UserMailer < ActionMailer::Base
  default from: "rakepage@rakepage.com"
  def welcome_email_no_rake(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "welcome_email_no_rake")
    headers['X-MC-Track'] = "opens, clicks"
  end
end
