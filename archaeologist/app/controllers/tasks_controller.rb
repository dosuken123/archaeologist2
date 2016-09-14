class TasksController < AuthController

	# def create
	# 	@task = Task.new(task_params)

	# 	@task.user_id = session[:login_user_id]
	# 	@task.task_status = Settings.task_status[:todo]

	# 	if @task.save
	# 		redirect_to histories_path
	# 	else
	# 		render template: "histories#index"
	# 	end
	# end

	def index
		# Fetch all datas
		@histories, @total_working_sec, @total_breaking_sec = HistoriesController.fetch_recent_history_group
		# @projects = Project.where("del_flg = ?", "0")
		@projects = Project.all
		@tasks_todo = self.class.fetch_todo_tasks
		@tasks_pend = self.class.fetch_pend_tasks
		@tasks_done = self.class.fetch_done_tasks
	end

	def create
		@task = Task.new(task_params)
		@task.user_id = session[:login_user_id]
		@task.task_status = Settings.task_status[:todo]
		@task.save

		# @tasks = Task.all
		# params[:user_id] = session[:login_user_id]
		# params[:task_status] = Settings.task_status[:todo]
  #   	@task = Task.create(task_params)

  		# Fetch informations to reload TODO List
  		# @tasks_todo = Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing])
  		@tasks_todo = self.class.fetch_todo_tasks
		@projects = Project.all
	end

	def new
		@task = Task.new
		@projects = Project.all
	end

	def update
		@task = Task.find(params[:id])
		@task.update(task_params)
		# redirect_to histories_path
		# resopnd_toを使うことで、JSON形式やXMLなどの形式でデータを返すことができます。
		respond_to do |format|
		    format.html { redirect_to histories_path, notice: 'Post was successfully updated.' }
		    format.json { head :no_content } 
		end
	end

	def off
		HistoriesController.mark_history session[:login_user_id], 1, 1, 1
		self.class.clear_doing

		# Oct 30th to AJAX
		# redirect_to histories_path

		# Fetch specific datas for reloading particular areas
		@histories, @total_working_sec, @total_breaking_sec = HistoriesController.fetch_recent_history_group
		# @projects = Project.where("del_flg = ?", "0")
		@projects = Project.all
		@tasks_todo = self.class.fetch_todo_tasks
		@tasks_pend = self.class.fetch_pend_tasks
		@tasks_done = self.class.fetch_done_tasks
	end

	def self.clear_doing
		# update other status to todo from doing
		Task.where("task_status = ?", Settings.task_status[:doing]).update_all(:task_status => Settings.task_status[:todo])
	end

	 #  create_table "tasks", force: :cascade do |t|
  #   t.integer  "user_id"
  #   t.integer  "project_id"
  #   t.text     "task_name"
  #   t.integer  "task_status", default: 0, null: false
  #   t.text     "memo"
  #   t.integer  "del_flg",     default: 0, null: false
  #   t.datetime "created_at",              null: false
  #   t.datetime "updated_at",              null: false
  # end

	def self.fetch_todo_tasks
		return Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing]).order('project_id')
	end		

	def self.fetch_pend_tasks
		return Task.where("task_status = ?", Settings.task_status[:pend]).order('project_id')
	end		

	def self.fetch_done_tasks
		# @tasks_done = Task.where("task_status = ?", Settings.task_status[:done])
		return Task.where("task_status = ? AND updated_at >= ?", Settings.task_status[:done], Time.now - 14.days).order('project_id')
	end		

	def update_status
		
		if params[:new_status].to_i == Settings.task_status[:doing] then
			self.class.clear_doing
		end
		
		@task = Task.find(params[:id])
		@task.prev_task_status = @task.task_status;	# Oct 29th to AJAX

		# if user set pend or done, even though its status is doings, Set off
		# puts "params[:new_status] = #{params[:new_status]}"
		# puts "@task.task_status = #{@task.task_status}"
		if (params[:new_status].to_i == Settings.task_status[:pend] || 
			params[:new_status].to_i == Settings.task_status[:done]) &&
			(@task.task_status == Settings.task_status[:doing]) then
			# # if user set pend or done, even though its status is doings
			# task_todo_first = Task.where("task_status = ?", Settings.task_status[:todo]).first
			# if task_todo_first != nil then
			# 	task_todo_first.update_attribute(:task_status, Settings.task_status[:doing])
			# end
			HistoriesController.mark_history session[:login_user_id], 1, 1, 1
			
		end

		# update target task's status
		@task.update_attribute(:task_status, params[:new_status])

		# mark history
		if params[:new_status].to_i == Settings.task_status[:doing] then
			HistoriesController.mark_history session[:login_user_id], @task.project_id, @task.id, 0
		end

		# if there are nothing of todo tasks, set OFF forceibly
		tasks_todo_count = Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing]).count
		if tasks_todo_count == 0 then
			HistoriesController.mark_history session[:login_user_id], 1, 1, 1
		end

		# Oct 28th 
		# respond_to do |format|
		# 	format.html { redirect_to histories_path, notice: 'User was successfully created.' }
		# 	format.js   {}
		# 	format.json { render json: @task, status: :updated, location: @task }
		# end
		# respond_to do |format|
		#     format.html { redirect_to histories_path, notice: 'Post was successfully updated.' }
		#     format.json { head :no_content } 
		# end

		# Oct 29th to AJAX
		# redirect_to histories_path

		# Fetch informations to reload TODO List
		@projects = Project.all
  		# @tasks_todo = Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing])
  		@tasks_todo = self.class.fetch_todo_tasks
		@tasks_pend = self.class.fetch_pend_tasks
		@tasks_done = self.class.fetch_done_tasks
		@histories, @total_working_sec, @total_breaking_sec = HistoriesController.fetch_recent_history_group
	end

	# def update_status
		
	# 	if params[:new_status].to_i == Settings.task_status[:doing] then
	# 		self.class.clear_doing
	# 	end
		
	# 	@task = Task.find(params[:id])

	# 	# if user set pend or done, even though its status is doings, Set off
	# 	# puts "params[:new_status] = #{params[:new_status]}"
	# 	# puts "@task.task_status = #{@task.task_status}"
	# 	if (params[:new_status].to_i == Settings.task_status[:pend] || 
	# 		params[:new_status].to_i == Settings.task_status[:done]) &&
	# 		(@task.task_status == Settings.task_status[:doing]) then
	# 		# # if user set pend or done, even though its status is doings
	# 		# task_todo_first = Task.where("task_status = ?", Settings.task_status[:todo]).first
	# 		# if task_todo_first != nil then
	# 		# 	task_todo_first.update_attribute(:task_status, Settings.task_status[:doing])
	# 		# end
	# 		HistoriesController.mark_history session[:login_user_id], 1, 1, 1
			
	# 	end

	# 	# update target task's status
	# 	@task.update_attribute(:task_status, params[:new_status])

	# 	# mark history
	# 	if params[:new_status].to_i == Settings.task_status[:doing] then
	# 		HistoriesController.mark_history session[:login_user_id], @task.project_id, @task.id, 0
	# 	end

	# 	# if there are nothing of todo tasks, set OFF forceibly
	# 	tasks_todo_count = Task.where("task_status = ? OR task_status = ? ", Settings.task_status[:todo], Settings.task_status[:doing]).count
	# 	if tasks_todo_count == 0 then
	# 		HistoriesController.mark_history session[:login_user_id], 1, 1, 1
	# 	end

	# 	# Oct 28th 
	# 	# respond_to do |format|
	# 	# 	format.html { redirect_to histories_path, notice: 'User was successfully created.' }
	# 	# 	format.js   {}
	# 	# 	format.json { render json: @task, status: :updated, location: @task }
	# 	# end
	# 	# respond_to do |format|
	# 	#     format.html { redirect_to histories_path, notice: 'Post was successfully updated.' }
	# 	#     format.json { head :no_content } 
	# 	# end

	# 	redirect_to histories_path
	# end

private
	def task_params
		params.require(:task).permit(:user_id, :project_id, :task_name, :task_status, :memo, :del_flg)
	end

end

	 #  create_table "tasks", force: :cascade do |t|
  #   t.integer  "user_id"
  #   t.integer  "project_id"
  #   t.text     "task_name"
  #   t.integer  "task_status", default: 0, null: false
  #   t.text     "memo"
  #   t.integer  "del_flg",     default: 0, null: false
  #   t.datetime "created_at",              null: false
  #   t.datetime "updated_at",              null: false
  # end