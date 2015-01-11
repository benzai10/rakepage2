class UserMailer < ActionMailer::Base
  default from: "Rakepage <rakepage@rakepage.com>"
  def no_confirmed_email(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "Hi #{@user.username}, your account is ready for confirmation",
         template_path: "user_mailer",
         template_name: "no_confirmed_email")
    headers['X-MC-Track'] = "opens, clicks"
  end

  def welcome_email_no_rake(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
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

  def status_overview_email(user)
    @user = user
    @url = "http://rakepage.com"
    mail(to: @user.email,
         subject: "#{@user.username} - Today's Overview of Your Rakepage",
         template_path: "user_mailer",
         template_name: "status_overview_email")
    headers['X-MC-Track'] = "opens, clicks"
  end
end
