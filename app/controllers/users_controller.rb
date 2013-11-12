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
      render 'full_signup_success', layout: 'signup'
    else
      @user.act = false
      render 'full_signup_error', layout: 'signup'
    end
  end
  
  def edit
    @id = params[:id].to_i
    @user = User.find_by(id: current_user.id)
    if @id == current_user.id
      render layout: 'edit'
    else
      redirect_to days_index_path, notice: "そのページへはアクセスできません"
    end
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
      redirect_to root_path, notice: "ログインしてください" unless signed_in?
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
      
      mail.charset = 'utf-8' # It's important!
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
      if user == nil
        redirect_to root_path
        flash[:notice] = "無効な値が入力されました"
      elsif user.act == true
        redirect_to root_path
        flash[:notice] = "すでに登録済みです。"
      end
    end
    
    def resend_full_signup
      user = User.where(id: params[:full_signup][:id]).first
      if user == nil
        redirect_to root_path
        flash[:notice] = "無効な値が入力されました"
      elsif user.act == true
        redirect_to root_path
        flash[:notice] = "すでに登録済みです。"
      end
    end
    
    def full_signup
      require 'mail'
      defined?(MAIL_SECRET)
      user = User.find_by(id: params[:full_signup][:id])
      url = url_for(controller: "users", action: "new")
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
      
      mail.charset = 'utf-8' # It's important!
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
