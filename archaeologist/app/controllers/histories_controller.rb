class HistoriesController < AuthController
	
	def index
		# Fetch all datas
		# @histories, @total_working_sec, @total_breaking_sec = self.class.fetch_recent_history_group
		@group_histories, @group_total_working_sec, @group_total_breaking_sec = self.class.fetch_all_history_group
		# @projects = Project.where("del_flg = ?", "0")
		@projects = Project.all
		@tasks_todo = TasksController.fetch_todo_tasks
		@tasks_pend = TasksController.fetch_pend_tasks
		@tasks_done = TasksController.fetch_done_tasks
	end

	def create
		@history = History.new(history_params)
		if @history.save
			redirect_to histories_path
		else
			render 'index'
		end
	end

	def self.fetch_recent_history_group
		histories = Array.new
		total_working_sec = 0
		total_breaking_sec = 0
		histories_all = History.all
		prev = nil
		for i in (histories_all.count-1).downto(0)
			hist = histories_all[i]
			if prev != nil then
				diff = (prev.created_at - hist.created_at)
				if diff < Settings.show_history[:distinction_min_hours] then
					if hist.is_off == 1 then
						total_breaking_sec += diff.to_i
					else
						total_working_sec += diff.to_i
					end
					histories.push hist
				else
					break
				end
			else
				# Check date
				# 27th Oct If it has been long while and it was OFF, consider it as next day.
				if ((Time.now - hist.created_at) > Settings.show_history[:distinction_min_hours]) && 
					(hist.is_off == 1) then
					break
				end
				histories.push hist
			end
			prev = hist
		end
		histories.reverse!

		return histories, total_working_sec, total_breaking_sec
	end

	def self.fetch_all_history_group
		group_histories = Array.new
		group_total_working_sec = Array.new
		group_total_breaking_sec = Array.new

		histories_all = History.order(created_at: :desc)
		cur_group_ind = 0
		group_histories.push(Array.new)
		group_total_working_sec.push(0)
		group_total_breaking_sec.push(0)

		# histories = Array.new
		# total_working_sec = 0
		# total_breaking_sec = 0
		# histories_all = History.all
		prev = nil
		(0..histories_all.count-1).each do |i|
		# for i in (histories_all.count-1).downto(0)
			hist = histories_all[i]
			if prev != nil then
				diff = (prev.created_at - hist.created_at)
				if hist.is_off == 1 && diff > Settings.show_history[:distinction_min_hours] then
					cur_group_ind += 1
					group_histories.push(Array.new)
					group_total_working_sec.push(0)
					group_total_breaking_sec.push(0)
					group_histories[cur_group_ind].push hist
				else
					if hist.is_off == 1 then
						group_total_breaking_sec[cur_group_ind] += diff.to_i
					else
						group_total_working_sec[cur_group_ind] += diff.to_i
					end
					# histories.push hist					
					group_histories[cur_group_ind].push hist
				end
			else
				# histories.push hist
				group_histories[cur_group_ind].push hist
			end
			prev = hist
		end

		(0..cur_group_ind).each do |i|
			group_histories[i].reverse!
		end
		group_histories.reverse!
		# histories.reverse!

		# return histories, total_working_sec, total_breaking_sec
		return group_histories, group_total_working_sec, group_total_breaking_sec
	end

	def self.mark_history(login_user_id, project_id, task_id, is_off)

		# puts "mark_history =#{project_id} #{task_id} #{is_off} PRE"
		while true do
			history_last = History.last
			break if history_last == nil
			# puts "mark_history 1"
			# block duplicated record
			if (is_off == 0 && history_last.project_id == project_id && history_last.task_id == task_id && history_last.is_off == 0) ||
				(is_off == 1 && history_last.is_off == 1) then
				# puts "mark_history 2"
				return true
			end

			# puts "mark_history 3"
			# if over threshold, replace it
			diff = Time.now - history_last.created_at
			if diff < Settings.append_history[:ignore_min_minutes] then
				history_last.destroy
				# puts "mark_history 4"
				next
			else
				break
			end
		end

		# puts "mark_history =#{project_id} #{task_id} #{is_off} DONE"

		history = History.new
		history.user_id = login_user_id
		history.project_id = project_id
		history.task_id = task_id
		history.is_off = is_off
		return history.save
	end

private
	def history_params
		params.require(:history).permit(:user_id, :project_id, :task_id, :total_sec, :del_flg)
	end
end

	# def index
	# 	# @user = User.find(session[:login_user_id])
	# 	# @histories = History.all
	# 	# get current group

	# 	# @histories = Array.new
	# 	# @total_working_sec = 0
	# 	# @total_breaking_sec = 0
	# 	# histories_all = History.all
	# 	# prev = nil
	# 	# for i in (histories_all.count-1).downto(0)
	# 	# 	hist = histories_all[i]
	# 	# 	if prev != nil then
	# 	# 		diff = (prev.created_at - hist.created_at)
	# 	# 		if diff < Settings.show_history[:distinction_min_hours] then
	# 	# 			if hist.is_off == 1 then
	# 	# 				@total_breaking_sec += diff.to_i
	# 	# 			else
	# 	# 				@total_working_sec += diff.to_i
	# 	# 			end
	# 	# 			@histories.push hist
	# 	# 		else
	# 	# 			break
	# 	# 		end
	# 	# 	else
	# 	# 		# Check date
	# 	# 		# 27th Oct If it has been long while and it was OFF, consider it as next day.
	# 	# 		if ((Time.now - hist.created_at) > Settings.show_history[:distinction_min_hours]) && 
	# 	# 			(hist.is_off == 1) then
	# 	# 			break
	# 	# 		end
	# 	# 		@histories.push hist
	# 	# 	end
	# 	# 	prev = hist
	# 	# end
	# 	# @histories.reverse!

	# 	# Fetch all datas
	# 	@histories, @total_working_sec, @total_breaking_sec = self.class.fetch_recent_history_group
	# 	@projects = Project.where("del_flg = ?", "0")
	# 	@tasks_todo = TasksController.fetch_todo_tasks
	# 	@tasks_pend = TasksController.fetch_pend_tasks
	# 	@tasks_done = TasksController.fetch_done_tasks

	# 	# debug
	# 	# @tasks = Task.all # For 
	# 	# @tasks_todo = Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing])
	# end