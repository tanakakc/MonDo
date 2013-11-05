# coding: utf-8

class UsersController < ApplicationController
before_action :signed_in_user, only: [:new]
before_action :are_you_authorized?, :are_you_full_signuped?, only: [:password]

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
      render 'pre_signup_success'
    else
      render 'pre_signup_error'
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
      render 'full_signup_success'
    else
      @user.act = false
      render 'full_signup_error'
    end
  end
    
  def login
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email)
    end
  
    def signed_in_user
      redirect_to days_index_path if signed_in?
    end
    
    def pre_signup
      require 'mail'
      user = User.find_by(email: params[:user][:email])
      hash_token = user.id.to_s + user.created_at.to_s + user.email
      hash_token = Digest::SHA1.hexdigest(hash_token.to_s)
      url = url_for(controller: "users", action: "password", id: user.id, hash_token: hash_token)
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
        to       user.email
        subject  "仮登録が完了しました！本文URLより本登録を済ませてください。"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/pre_signup.text.erb")).result binding
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
    
    def are_you_authorized?
      user = User.find_by(id: params[:id])
      hash_token = user.id.to_s + user.created_at.to_s + user.email
      authorized_token = Digest::SHA1.hexdigest(hash_token.to_s)
      redirect_to root_path unless params[:hash_token] == authorized_token
    end
    
    def are_you_full_signuped?
      user = User.where(id: params[:id]).first
      if user.act == true
        redirect_to root_path
        flash[:notice] = "すでに登録済みです。"
      end
    end
    
    def full_signup
      require 'mail'
      defined?(MAIL_SECRET)
      user = User.find_by(id: params[:full_signup][:id])
      url = url_for(controller: "sessions", action: "new")
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
        to       user.email
        subject  "本登録が完了しました！"
        body     ERB.new(File.read(Rails.root.to_s + "/app/views/mail_templates/full_signup.text.erb")).result binding
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
  
end
