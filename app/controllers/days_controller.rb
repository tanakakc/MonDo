# coding: utf-8

class DaysController < ApplicationController
before_action :signed_in_user, only: [:index, :new, :show]
before_action :started_user, only: [:index, :show]
before_action :How_many_days_passed?, only: [:index, :show, :edit]

  def index
    render layout: "days_index"
  end  
  
  def new
    @date = params[:id].to_i
    if are_you_first_time?
      unless @date == 1
        flash[:notice] = "まずは1日目の問いに答えましょう！"
        redirect_to '/days/1/new' and return
      else
        render layout: 'post'
      end
    else
      How_many_days_passed?
      if @passed_days <= 30 && @date != @passed_days
        flash[:notice] = "#{@passed_days}日目しか編集できません"
        redirect_to days_index_path and return
      elsif @passed_days >= 31
        if @date <= 0 || @date > @passed_days || @date > 30 || @date != @passed_days
          flash[:notice] = "30日経過しました。再チャレンジの場合は、ユーザーページからリセットを行ってください。"
          redirect_to days_index_path and return
        end
      end
    end

    if !are_you_first_time? && @passed_days <= 30
      @edit = Day.find_by(user_id: current_user.id, date: @date)
      @empty = 0
      [:q1, :q2, :q3, :q4].each do |i|
        if @edit[i].blank?
          @empty = @empty + 1
        end
      end 
    
      unless @empty == 4
        redirect_to controller: "days", action: "show", id: @date and return
      end
      render layout: 'post'
    end
  end

  def create
    @first_time = are_you_first_time?
    @date = params[:answer][:date]
    
    if @first_time 
      @answer = Day.new(answer_params)
      @answer.user_id = current_user.id
    else
      @answer = Day.find_by(user_id: current_user.id, date: @date)
      @answer.attributes = answer_params
    end
    
    @empty = 0
    
    [:q1, :q2, :q3, :q4].each do |i|
      if @answer[i].blank?
        @empty = @empty + 1
      end
    end    
    
    if @empty <= 3
      @answer.done = false
      if @empty == 0
        @answer.done = true
      end
      @answer.save
      if @first_time
        add_record
      end
      flash[:notice] = "投稿を完了しました！"
      redirect_to controller: "days", action: "show", id: @date
    elsif @empty == 4
      flash[:alert] = "１つ以上入力してください"
      redirect_to controller: "days", action: "show", id: @date
    end
  end
 
  def show
    @date = params[:id].to_i
    @edit = Day.find_by(user_id: current_user.id, date: @date)
    @answers = Day.where(user_id: current_user.id, date: @date)
    if @date <= 0 || @date > 30 || @date > @passed_days
      flash[:notice] = "無効な値が入力されました"
      redirect_to days_index_path and return
    end
    
    @empty = 0
    [:q1, :q2, :q3, :q4].each do |i|
      if @edit[i].blank?
        @empty = @empty + 1
      end
    end 
    
    if @empty == 4 && @date == @passed_days
      redirect_to controller: "days", action: "new", id: @date and return
    end
    render layout: "show"
  end
  
  #def edit
  #  @date = params[:id].to_i
  #  @edit = Day.find_by(user_id: current_user.id, date: @date)
  #	unless @date == @passed_days
  #	  flash[:notice] = "#{@passed_days}日目しか編集できません"
  #  redirect_to days_index_path
  #	end
  #end

  
  private
  
    # スタートして今、何日目かを確認
    def How_many_days_passed?
      @time_now = Time.now #今の時刻
      @first_day = Day.find_by(user_id: current_user.id) #レコードを1つ取得
      @first_day = @first_day.created_at - 3.hours #1日目レコードの作成日時を取得
      @first_day = @first_day.change(hour: 3, minutes: 0, seconds: 0)
      @dif = @time_now - @first_day #今と作成日時の差分を計算
      @dif = @dif.to_i #整数化
      @passed_days = @dif / (60 * 60 * 24) + 1 #秒を日に変換
    end
  
    # サインインしているかどうか確認
    def signed_in_user
      redirect_to root_path, notice: "ログインしてください" unless signed_in?
    end
    
    # はじめての訪問かどうか確認
    def are_you_first_time?
      Day.where(user_id: current_user.id).count == 0
    end
    
    # はじめての訪問でURLに1以外を入力された時の処理
    def  started_user
      if are_you_first_time?
        flash[:notice] = "まずは1日目の問いに答えましょう！"
        redirect_to '/days/1/new' and return
      end
    end
    
    # /days/:id/newからpostされたデータを保存する準備
    def answer_params
      params.require(:answer).permit(:q1, :q2, :q3, :q4, :date)
    end
    
    # 回答後のレコード追加の処理
    def add_record
      date = 2
      29.times do
        addrecord = Day.new(user_id: current_user.id, date: date)
        addrecord.save
        date = date + 1
      end
    end
    
end
