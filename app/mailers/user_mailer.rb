class UserMailer < ActionMailer::Base
  default from: "rakepage@rakepage.com"
  def welcome_email_no_rake(user)
    @user = user
    @url = "http://rakepage.com"
    mail(from_name: "Rakepage",
         to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "welcome_email_no_rake")
    headers['X-MC-Track'] = "opens, clicks"
  end

  def welcome_email_with_rake(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "welcome_email_with_rake")
    headers['X-MC-Track'] = "opens, clicks"
  end

  def reminder_email_no_rake(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "reminder_email_no_rake")
    headers['X-MC-Track'] = "opens, clicks"
  end

  def create_task_email(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "create_task_email")
    headers['X-MC-Track'] = "opens, clicks"
  end

  def active_tasks_email(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, master your priorities using Rakepage",
         template_path: "user_mailer",
         template_name: "active_tasks_email")
    headers['X-MC-Track'] = "opens, clicks"
  end

end
