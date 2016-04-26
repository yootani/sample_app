class User < ActiveRecord::Base
  # Relationship
  has_many :microposts, dependent: :destroy

  # "deppendent: :destroy" : foreign_key is deleted then delete it too
  has_many :relationships, foreign_key: "follower_id", dependent:   :destroy

  # to use 'reverse_relationships'
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship",  dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  has_many :followed_users, through: :relationships, source: :followed

  before_save { self.email = email.downcase}
  before_create :create_remember_token

  validates :name, presence: true , length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

 has_secure_password
 validates :password, length: {minimum: 6}


 def User.new_remember_token
   SecureRandom.urlsafe_base64
 end

 def User.encrypt(token)
   Digest::SHA1.hexdigest(token.to_s)
 end

 def feed
   # '?' is important in 'Security' [SQLinjection]

   # this code  is unperfect(Chap10.3.3)
   # --Modify perfect feed (Chap11.3.1)
   #   Micropost.where("user_id = ?", id)
   Micropost.from_users_followed_by(self)
 end

 # search 'followed user' by other_user
 def following?(other_user)
   relationships.find_by(followed_id: other_user.id)
 end

 # generate 'followed' Relation generarte
 def follow!(other_user)
   relationships.create!(followed_id: other_user.id)
 end

 # destroy 'followed User'
 def unfollow!(other_user)
   relationships.find_by(followed_id: other_user.id).destroy
 end


 private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
