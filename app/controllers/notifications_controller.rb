class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		nrcs = UserSubject.connection.execute("SELECT subject_id FROM user_subjects where user_id=36;")
		query = "recipient_id="+current_user.id.to_s
		nrcs.each do |nrc|
			query = query + " or recipient_id="+nrc[0].to_s
		end
		@notifications = Notification.where(query).unread
	end

end