json.array! @notifications do |notification|
	json.recipient notification.recipient_id
	json.actor notification.actor_id
	json.action notification.action
	json.notifiable notification.notifiable_id
	json.notifiable_type notification.notifiable_type
	#json.url dashboard_path(notification)
end