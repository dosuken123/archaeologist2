class AuthController < ApplicationController
	before_filter :login_required

private
	# ログインしていなければログイン画面へリダイレクト
	def login_required
    	if session[:login_user_id] && User.exists?(:id => session[:login_user_id])
			@user = User.find(session[:login_user_id])
		else
			redirect_to logout_users_path
		end
	end
end