class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	attr_accessor :prev_task_status
end
