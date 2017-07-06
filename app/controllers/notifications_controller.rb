class NotificationsController < ApplicationController
	before_action :authenticate_user!

	#Intento de tabla sin tanto spam, pero por los unread y read_at no es posible
	#nrcs = UserSubject.connection.execute("SELECT subject_id FROM user_subjects where user_id="+current_user.id.to_s+";")
	#query = "recipient_id="+current_user.id.to_s
	#nrcs.each do |nrc|
	#	query = query + " or recipient_id="+nrc[0].to_s
	#end

	def index
		@notifications = Notification.where(recipient_id: current_user.id).unread
	end

	def mark_as_read
		@notifications = Notification.where(recipient_id: current_user.id).unread
		@notifications.update_all(read_at: Time.zone.now)
		render json: {success: true}
	end

end