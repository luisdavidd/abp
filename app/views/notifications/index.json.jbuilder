paths = {"Offer" => "shopping_student",
		"Auction" => "auction_student",
		"Transaction" => "historicalTransactions"
		}

#diccionario para los iconos basandose en la accion que entra


# Christian added Parcial 1 - Punto 1 (offer)
# Christian added Parcial 1 - Punto 1 (auction)
# Juan wants to tranfer Luis 400 bacs

# Christian aproved the transaction from Juan to Luis for 400 bacs  
# Christian denied the transaction from Juan to Luis for 400 bacs 
json.array! @notifications do |notification|
	#json.recipient notification.recipient_id
	json.url paths[notification.notifiable_type]
	json.actor notification.actor
	json.action notification.action
	json.notifiable notification.notifiable_id
	json.notifiable_type notification.notifiable_type
	json.notifiable notification.notifiable
	msg = "(#{notification.notifiable.nrc}) #{notification.actor.name} #{notification.actor.last_name} #{notification.action} ";
	if notification.notifiable_type == "Offer" || notification.notifiable_type == "Auction"
		msg += "#{notification.notifiable.name}"
	else #if it is transaction
		if notification.action == "wants to tranfer"
			msg += "Luis 400 bacs"
			
		else
			msg += "the transaction from Juan to Luis"
		end
	end
	json.msg msg
end