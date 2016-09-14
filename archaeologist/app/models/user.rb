class User < ActiveRecord::Base
	has_many :tasks
	validates :user_name, uniqueness: true
end
