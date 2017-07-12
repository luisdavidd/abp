class HomeController < ApplicationController
	def index
		@numTeachers = User.where(teacher: 1).count
		@numStudents = User.where(teacher: 0).count
	end
end
