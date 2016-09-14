class UsersController < ApplicationController
	
	def index
		# root
		# if session[:login_user_id] then
		# 	redirect_to histories_path
		# end
	end

	def signin
		@error_msg = nil;
		@user = User.find_by(user_name: params[:user][:user_name])
		if @user
			# Session
			session[:login_user_id] = @user.id
			redirect_to tasks_path
		else
			session[:login_user_id] = nil
			@error_msg = "Couldn't find your name : " + params[:user][:user_name];
			render 'index'
		end
	end

	def logout
		session[:login_user_id] = nil
		redirect_to users_path
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			redirect_to users_path
		else
			render 'new'
		end
	end

private
	def user_params
		params.require(:user).permit(:user_name, :icon_path, :background_image_path, :create_date, :update_date, :del_flg)
	end
end
