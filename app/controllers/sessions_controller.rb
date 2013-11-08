# coding: utf-8

class SessionsController < ApplicationController
before_action :signed_in_user, only: [:new]

  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user.nil? || user.password_digest.nil?
      redirect_to root_path, alert: '入力情報に誤りがあります' and return
    end
    authrized_user = user.authenticate(params[:session][:password])
    if authrized_user
      sign_in user
      redirect_to days_index_path
    else
      redirect_to root_path, alert: '入力情報に誤りがあります'
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  private

    def signed_in_user
      redirect_to days_index_path if signed_in?
    end

end
