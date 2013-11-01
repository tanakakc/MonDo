require 'mail'

class BatchEmail

  def self.send_mail#(email)
    email = "kc@toiee.jp"
    mail = Mail.new do
      from     ENV.fetch("SMTP_USERNAME", MAILSECRET[:email])
      to       "kc@toiee.jp"
      subject  "test"
      body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/body.text.erb")).result binding
    end
    
    mail.delivery_method(:smtp,
      address:         'smtp.gmail.com',
      port:            '587',
      domain:          'smtp.gmail.com',
      authentication:  'plain',
      user_name:       ENV.fetch("SMTP_USERNAME", MAILSECRET[:email]),
      password:        ENV.fetch("SMTP_PASSWD", MAILSECRET[:password])
    )
    
    mail.deliver
  end
  
  def self.get_name_and_email
    @find = Day.where(date: "1").pluck(:user_id, :created_at)
    @find.each do |i|
      @user_info = User.where(id: i[0]).pluck(:name, :email).first
      
      @time_fix = i[1] - 3.hours
      @time_fix = Time.now - @time_fix
      @time_fix = @time_fix.to_i
      @passed_days = @time_fix / (60 * 60 * 24) + 1
      
      unless @passed_days >= 31 || @passed_days < 2
        self.send_mail(@user_info[1])
      end
      
    end
  end
  
end