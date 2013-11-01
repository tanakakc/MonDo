class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true #{ message: "に入力してください" }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, 
  presence: true, #{ message: "に入力してください" },
  uniqueness: { case_sensitive: false, message: "はすでに登録済みです" },
  format: { with: VALID_EMAIL_REGEX } #, message: "のフォーマットを確認してください" }
  
  has_secure_password validations: false
  validates_confirmation_of :password, if: lambda { |m| m.password.present? }, on: :update
  validates_presence_of     :password, on: :update
  validates_presence_of     :password_confirmation, if: lambda { |m| m.password.present? }, on: :update
  validates :password, length: {minimum: 6}, on: :update
  
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  private
  
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
