class PasswordResetsController < ApplicationController
before_action :signed_in_user

  def new
    render layout: 'signup'
  end
  
  def create
    user = User.find_by(email: params[:user][:email])
    if user
      user.prepare_password_reset
      reset_password_mail_deliver
    else
      flash[:alert] = "入力されたメールアドレスは登録されていません"
      redirect_to password_resets_new_path and return
    end
    redirect_to root_path, :notice => "パスワード再設定用のメールを送信しました"
  end
  
  def edit
    @user = User.find_by_password_reset_token!(params[:hash_token])
    render layout: 'signup'
  end
  
  def update
    @user = User.find_by_password_reset_token!(params[:hash_token])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to password_resets_new_path, :alert => "URLの有効期限が切れています。再度メールアドレスを入力してください。"
    elsif @user.update_attributes(user_params)
      completed_reset_password
      redirect_to root_path, :notice => "パスワード再設定が完了しました！"
    else
      render 'edit', layout: 'signup'
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    def signed_in_user
      redirect_to days_index_path if signed_in?
    end
  
    def reset_password_mail_deliver
      require 'mail'
      
      user = User.find_by(email: params[:user][:email])
      url = url_for(controller: "password_resets", action: "edit", hash_token: user.password_reset_token)
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
        to       user.email
        subject  "【MonDo】パスワード再設定用のURL"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/password_reset.text.erb")).result binding
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
    
      mail.deliver
    end
    
    def completed_reset_password
      require 'mail'
      
      user = @user
      url = url_for(controller: "users", action: "new")
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
        to       user.email
        subject  "【MonDo】パスワード再設定用が完了しました"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/complete_password_reset.text.erb")).result binding
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
    
      mail.deliver
    end
end
