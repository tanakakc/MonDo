# coding: utf-8

class UsersController < ApplicationController
before_action :signed_in_user, only: [:new]
before_action :signed_in_user2, only: [:edit, :update]
before_action :are_you_full_signuped?, :are_you_authorized?, only: [:password]
before_action :resend_full_signup, only: [:password_create]

  def index
  end
  
  def detail
    render layout: 'detail'
  end

  def new
    render layout: 'signup'
  end

  def create
    @user = User.new(user_params)
    if @user.save
      pre_signup
      render 'pre_signup_success', layout: 'signup'
    else
      render 'pre_signup_error', layout: 'signup'
    end
  end
  
  def password
    @user_id = params[:id]
    render layout: 'signup'
  end

  def password_create
    @user = User.where(id: params[:full_signup][:id]).first
    @user.update_attributes(password: params[:full_signup][:password], password_confirmation: params[:full_signup][:password_confirmation], act: true)
    if @user.save
      full_signup
      sign_in @user
      render 'full_signup_success', layout: 'signup'
    else
      @user.act = false
      render 'full_signup_error', layout: 'signup'
    end
  end
  
  def edit
    @user = User.find_by(id: current_user.id)
    render layout: 'edit'
  end
  
  def update
    @user = User.find_by(id: current_user.id)
    if @user && @user.update_attributes(user_edit_params)
      flash[:notice] = "ユーザー情報を更新しました！"
      redirect_to controller: "users", action: "edit", id: current_user.id and return
    else
      render 'edit', layout: 'edit'
    end
  end
  
  def select_mail
    @user = User.find_by(id: current_user.id)
    
    @user.receive_mail = params[:select_mail][:receive_mail]
    
    if @user.save!(validate: false)
      flash[:notice] = "メール配信設定を変更しました！"
      redirect_to controller: "users", action: "edit", id: current_user.id and return
    end
  end
  
  def destroy
    @user = User.find_by_id(current_user.id)
    @user_mondo = Day.where(user_id: @user.id)
    
    if delete_account_sendmail
      @user_mondo.destroy_all
      @user.destroy
      flash[:notice] = "アカウント削除が正常に完了しました！"
      redirect_to root_path and return
    end
  
  end
  
  def privacy_policy
   render layout: 'detail'
  end
    
  private
  
    def user_params
      params.require(:user).permit(:name, :email)
    end
    
    def user_edit_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
    def signed_in_user
      redirect_to days_index_path if signed_in?
    end
    
    def signed_in_user2
      redirect_to root_path, alert: "ログインしてください" unless signed_in?
    end
        
    def pre_signup
      require 'mail'
      user = User.find_by(email: params[:user][:email])
      hash_token = user.id.to_s + user.created_at.to_s + user.email
      hash_token = Digest::SHA1.hexdigest(hash_token.to_s)
      url = url_for(controller: "users", action: "password", id: user.id, hash_token: hash_token)
      
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
        subject  "【MonDo】#{user.name}さま、本登録をお願いします"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/pre_signup.text.erb")).result binding
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
    
    def are_you_authorized?
      user = User.find_by(id: params[:id])
      hash_token = user.id.to_s + user.created_at.to_s + user.email
      authorized_token = Digest::SHA1.hexdigest(hash_token.to_s)
      redirect_to root_path unless params[:hash_token] == authorized_token
    end
    
    def are_you_full_signuped?
      user = User.where(id: params[:id]).first
      if user == nil
        redirect_to root_path
        flash[:alert] = "無効な値が入力されました"
      elsif user.act == true
        redirect_to root_path
        flash[:alert] = "すでに登録済みです。"
      end
    end
    
    def resend_full_signup
      user = User.where(id: params[:full_signup][:id]).first
      if user == nil
        redirect_to root_path
        flash[:alert] = "無効な値が入力されました"
      elsif user.act == true
        redirect_to root_path
        flash[:alert] = "すでに登録済みです。"
      end
    end
    
    def full_signup
      require 'mail'
      user = User.find_by(id: params[:full_signup][:id])
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
        subject  "【MonDo】ようこそ、MonDoへ！"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/full_signup.text.erb")).result binding
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
    
    def delete_account_sendmail
      require 'mail'
      user = User.find_by_id(current_user.id)
      
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
        subject  "【MonDo】MonDoの退会処理が完了しました！"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/delete_account.text.erb")).result binding
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
