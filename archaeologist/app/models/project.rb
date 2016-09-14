class Project < ActiveRecord::Base
	has_many :tasks
	attr_accessor :imageobject
end
