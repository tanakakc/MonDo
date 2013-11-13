class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, 
  presence: true,
  uniqueness: { case_sensitive: false, message: "はすでに登録済みです" },
  format: { with: VALID_EMAIL_REGEX } 
  
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
  
  def prepare_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(:validate => false)
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  private
  
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
    
    
end
