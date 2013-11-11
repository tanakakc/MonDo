require 'mail'
include Rails.application.routes.url_helpers

class Batch::BatchEmail

  def self.send_mail(email, date)
    default_url_options[:host] = "mondo30.herokuapp.com"
    url = url_for(controller: "days", action: "new", id: date)
    if defined?(MAIL_SECRET)
      user_name = MAIL_SECRET[:email]
    else
      user_name = ENV["SMTP_USERNAME"]
    end
                  
    if defined?(MAIL_SECRET)
      passwd = MAIL_SECRET[:password]
    else
      passwd = ENV["SMTP_PASSWD"]
    end
    mail = Mail.new do
      from     user_name
      to       email
      subject  "test"
      body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/body.text.erb")).result binding
    end
    
    mail.delivery_method(:smtp,
      address:         'smtp.gmail.com',
      port:            '587',
      domain:          'smtp.gmail.com',
      authentication:  'plain',
      user_name:       user_name,
      password:        passwd
    )
    
    mail.deliver
  end
  
  def self.get_name_and_email
    @find = Day.where(date: "1").pluck(:user_id, :created_at)
    @find.each do |i|
      @user_info = User.where(id: i[0]).pluck(:name, :email).first
      
      @time_fix = i[1] - 3.hours
      @time_fix = @time_fix.change(hour: 3, minutes: 0, seconds: 0)
      @time_fix = Time.zone.now - @time_fix
      @time_fix = @time_fix.to_i
      @passed_days = @time_fix / (60 * 60 * 24) + 1
      
      unless @passed_days >= 31 || @passed_days < 2
        self.send_mail(@user_info[1], @passed_days)
      end
      
    end
  end
  
end