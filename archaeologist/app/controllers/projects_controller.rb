require 'kconv'	# -> toutf8
class ProjectsController < AuthController

	def index
		# @projects = Project.all
		@projects = Project.where("del_flg = ?", "0")
	end

	# def new
	# 	@project = Project.new
	# end

	def edit
		@project = Project.find(params[:id])
	end

	def create
		@project = Project.new(project_params)

		# save uploaded image
		image = project_params[:imageobject]
		result = "success"
		if image != nil then
			image_name = image.original_filename
			@project.icon_path = image.original_filename
			result = uploadimg(image,image_name)
		else
			icon_path = self.class.generate_unduplicated_icon(@project[:project_name])
			@project.icon_path = icon_path
			# proj_name = @project[:project_name].clone
			# w = h = 50
			# base_color = ['#1abc9c', '#2ecc71', '#3498db', '#9b59b6', '#34495e', 
			# 	'#16a085', '#27ae60', '#2980b9', '#8e44ad', '#2c3e50', 
			# 	'#f1c40f', '#e67e22', '#e74c3c', '#ecf0f1', '#95a5a6',
			# 	'#f39c12', '#d35400', '#c0392b', '#bdc3c7', '#7f8c8d']
			# text_color = ['#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE',
			# 		'#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE',
			# 		'#EEEEEE', '#EEEEEE', '#EEEEEE', '#CCCCCC', '#EEEEEE',
			# 		'#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE', '#EEEEEE']
			# color_index = rand(base_color.count)

			# # TODO: Generate default image
			# # image = Magick::Image.new(100, 100) 
			# image = Magick::Image.new(w*2, h*2)  do |c|
			# 	c.background_color = base_color[color_index]
			# end
			# # image = image.rotate(45)
			# # image.background_color = 'red'
			# # image = Magick::ImageList.new 'octcat.png' # ImageList.new file_path で画像読み込み
			# text = Magick::Draw.new
			# # text.font_family = '/System/Library/Fonts/Avenir Next.ttc'
			# text.gravity = Magick::CenterGravity
			# w1 = Math.sqrt(w*w+h*h)
			# h1 = w1
			# if proj_name.length <= 6 then
			# 	# 1 line (1~6)
			# 	offset_x = 2
			# 	offset_y = 3
			# 	text.pointsize = 15
			# 	text.annotate(image, w1,h1,(w*2-w1)/2+offset_x,(h*2-h1)/2+offset_y, proj_name) {
			# 		self.fill = text_color[color_index]
			# 	}
			# else
			# 	# 2 line (1~5) each
			# 	offset_x = 1
			# 	offset_y = 3
			# 	text.pointsize = 12
			# 	proj_name = proj_name[0, 12] if proj_name.length > 12 
			# 	proj_name.insert(6,'\n')
			# 	text.annotate(image, w1,h1,(w*2-w1)/2+offset_x,(h*2-h1)/2+offset_y, proj_name) {
			# 		self.fill = text_color[color_index]
			# 	}
			# end

			# # Rotate and crop
			# image = image.rotate(-45)
			# image.crop!(w/2,h/2,w,h)
			# # Generate icon name
			# new_icon_name = @project[:project_name].clone
			# fullpath = self.class.combine_image_fullpath(new_icon_name+'.png')
			# while true
			# 	if !File.exist?(fullpath)
			# 		break
			# 	end
			# 	new_icon_name += '_'
			# 	fullpath = self.class.combine_image_fullpath(new_icon_name+'.png')
			# end
			# # save to icon dir
			# @project.icon_path = new_icon_name + '.png'
			# image.write(fullpath)
		end

		if result == "success" && @project.save
			redirect_to projects_path
		else
			# Delete img
			fullpath = self.class.combine_image_fullpath(@project.icon_path)
			File.unlink fullpath if File.exist?(fullpath)
			redirect_to projects_path	# TODO: Error msg
		end
	end

	def update
		@project = Project.find(params[:id])

		if @project.update(project_params)
			redirect_to projects_path
		else 
			render 'edit'
		end
	end

	def destroy
		@project = Project.find(params[:id])
		# @project.destroy
		# Delete img
		fullpath = self.class.combine_image_fullpath(@project.icon_path)
		File.unlink fullpath if File.exist?(fullpath)
		@project.update_attribute(:del_flg, 1)
		redirect_to projects_path
	end

	def generate_default_icon
		@project = Project.find(params[:id])
		# Delete img
		if @project.icon_path != nil then
			fullpath = self.class.combine_image_fullpath(@project.icon_path)
			File.unlink fullpath if File.exist?(fullpath)
		end
		# save to icon dir
		icon_path = self.class.generate_unduplicated_icon(@project[:project_name])
		@project.update_attribute(:icon_path, icon_path)
		redirect_to projects_path
	end

	def self.combine_image_fullpath(image_name)
		return Settings.uploads[:common_dir]+Settings.uploads[:project_icon_dir]+image_name.toutf8
	end

	def self.generate_unduplicated_icon(src_icon_name)
		proj_name = src_icon_name.clone
		w = h = 50
		base_color = ['#1abc9c', '#2ecc71', '#3498db', '#9b59b6', '#34495e', 
			'#16a085', '#27ae60', '#2980b9', '#8e44ad', '#2c3e50', 
			'#f1c40f', '#e67e22', '#e74c3c', '#ecf0f1', '#95a5a6',
			'#f39c12', '#d35400', '#c0392b', '#bdc3c7', '#7f8c8d']
		text_color = ['#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF',
				'#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF',
				'#FFFFFF', '#FFFFFF', '#FFFFFF', '#AAAAAA', '#FFFFFF',
				'#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF']
		color_index = rand(base_color.count)

		# TODO: Generate default image
		# image = Magick::Image.new(100, 100) 
		image = Magick::Image.new(w*2, h*2)  do |c|
			c.background_color = base_color[color_index]
		end
		# image = image.rotate(45)
		# image.background_color = 'red'
		# image = Magick::ImageList.new 'octcat.png' # ImageList.new file_path で画像読み込み
		text = Magick::Draw.new
		# text.font_family = '/System/Library/Fonts/Avenir Next.ttc'
		text.gravity = Magick::CenterGravity
		w1 = Math.sqrt(w*w+h*h)
		h1 = w1
		if proj_name.length <= 6 then
			# 1 line (1~6)
			offset_x = 2
			offset_y = 3
			text.pointsize = 15
			text.annotate(image, w1,h1,(w*2-w1)/2+offset_x,(h*2-h1)/2+offset_y, proj_name) {
				self.fill = text_color[color_index]
			}
		else
			# 2 line (1~5) each
			offset_x = 1
			offset_y = 3
			text.pointsize = 12
			proj_name = proj_name[0, 12] if proj_name.length > 12 
			proj_name.insert(6,'\n')
			text.annotate(image, w1,h1,(w*2-w1)/2+offset_x,(h*2-h1)/2+offset_y, proj_name) {
				self.fill = text_color[color_index]
			}
		end

		# Rotate and crop
		image = image.rotate(-45)
		image.crop!(w/2,h/2,w,h)
		# Generate icon name
		new_icon_name = src_icon_name.clone
		fullpath = combine_image_fullpath(new_icon_name+'.png')
		while true
			if !File.exist?(fullpath)
				break
			end
			new_icon_name += '_'
			fullpath = combine_image_fullpath(new_icon_name+'.png')
		end
		# save to icon dir
		image.write(fullpath)
		return new_icon_name + '.png'
	end

	# def self.generate_unduplicated_icon_name(original_icon_name)
	# 	# Generate icon name
	# 	new_icon_name = original_icon_name.clone
	# 	fullpath = combine_image_fullpath(new_icon_name+'.png')
	# 	while true
	# 		if !File.exist?(fullpath)
	# 			break
	# 		end
	# 		new_icon_name += '_'
	# 		fullpath = self.class.combine_image_fullpath(new_icon_name+'.png')
	# 	end
	# 	return new_icon_name, fullpath
	# end

private
	def project_params
		params.require(:project).permit(:project_name, :imageobject, :del_flg)
	end


# # # write file
# 			#uploaded_io = params[:project][:icon_path]
# 			uploaded_io = params[:project][:imageobject]
# 			File.open(Rails.root.join('public', 'uploads', 'project_image', uploaded_io.original_filename), 'wb') do |file|
# 				file.write(uploaded_io.read)
# 			end

	def uploadimg(img_object,image_name)
		ext = image_name[image_name.rindex('.') + 1, 4].downcase
		perms = ['.jpg', '.jpeg', '.gif', '.png']
		if !perms.include?(File.extname(image_name).downcase)
			result = 'アップロードできるのは画像ファイルのみです。'
		elsif img_object.size > 4.megabyte
			result = 'ファイルサイズは4MBまでです。'
		else
			File.open(Settings.uploads[:common_dir]+ \
				Settings.uploads[:project_icon_dir]+ \
				"#{image_name.toutf8}", 'wb') { |f| f.write(img_object.read) }
			result = "success"
		end
		return result
	end

	# def deleteimg(image_name)
	# 	File.unlink Settings.uploads[:common_dir]+ \
	# 	Settings.uploads[:project_icon_dir]+ \
	# 	image_name.toutf8
	# end

end
