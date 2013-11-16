# coding: utf-8

require 'mail'
include Rails.application.routes.url_helpers

class Batch::BatchEmail

  def self.send_mail(email, date, content)
    if defined?(DEV_URL)
      default_url_options[:host] = DEV_URL
    else
      default_url_options[:host] = ENV["PDC_URL"]
    end
    url = url_for(controller: "days", action: "new", id: date)
    user = User.find_by(email: email)
    
    if defined?(MAIL_SECRET)
        user_address = MAIL_SECRET[:email]
        text_address = "\"MonDo App\" <#{user_address}>"
        make_user = Mail::Address.new(text_address)
        user_name = make_user.format   
      else
        user_address = ENV["SMTP_USERNAME"]
        text_address = "\"MonDo App\" <#{user_address}>"
        make_user = Mail::Address.new(text_address)
        user_name = make_user.format
      end
                  
    if defined?(MAIL_SECRET)
      passwd = MAIL_SECRET[:password]
    else
      passwd = ENV["SMTP_PASSWD"]
    end
    mail = Mail.new do
      from     user_name
      to       email
      subject  "【MonDo】30日チャレンジ：#{date}日目"
      body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/daily_email.text.erb")).result binding
    end
    
    mail.charset = 'utf-8' # It's important!
    mail.delivery_method(:smtp,
      address:         'smtp.gmail.com',
      port:            '587',
      domain:          'smtp.gmail.com',
      authentication:  'plain',
      user_name:       user_address,
      password:        passwd
    )
    
    if mail.deliver
      user_id = User.find_by(email: email).id
      user = Day.find_by(user_id: user_id, date: date)
      user.mail_done = true
      user.save
    else
      user.mail_done = false
      user.save
    end
  end
  
  def self.get_name_and_email
    @find = Day.where(date: "1").pluck(:user_id, :created_at)
    @step_mails = StepMail.all.index_by(&:date) #StepMailテーブルの、dateカラムをkeyにハッシュを作成
    @find.each do |i|
      @user_info = User.where(id: i[0]).pluck(:name, :email).first
      
      @time_fix = i[1] - 3.hours
      @time_fix = @time_fix.change(hour: 3, minutes: 0, seconds: 0)
      @time_fix = Time.zone.now - @time_fix
      @time_fix = @time_fix.to_i
      @passed_days = @time_fix / (60 * 60 * 24) + 1
      
      if @passed_days < 31
        @content = @step_mails[@passed_days][:content]
      end
      
      unless @passed_days >= 31 || @passed_days < 2
        self.send_mail(@user_info[1], @passed_days, @content)
      end
      
    end
  end
  
end