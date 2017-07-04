class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		@notifications = Notifications.where(recipient: current_user).unread
	end

end