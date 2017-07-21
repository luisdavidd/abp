paths = {"Offer" => "shopping_student",
		"Auction" => "auction_student",
		"Transaction" => "historicalTransactions",
		"StatusLoan_true" => "loans_teacher",
		"StatusLoan_false" => "loans_student"
		}

#diccionario para los iconos basandose en la accion que entra
iconos = {"wants to transfer" => "fa fa-exchange text-aqua",
		  "wants to lend" => "fa fa-money text-aqua",
		  "transfer" => "fa fa-exchange text-aqua",
		  "approved" => "fa fa-check-circle text-aqua",
		  "rejected" => "fa fa-window-close text-aqua",
		  "added" => "fa fa-plus-circle text-aqua"
		}

# Christian added Parcial 1 - Punto 1 (offer)
# Christian added Parcial 1 - Punto 1 (auction)?

# Juan wants to tranfer Luis 400 bacs
# Christian aproved the transaction from Juan to Luis for $400  
# Christian denied the transaction from Juan to Luis for $400 
json.array! @notifications do |notification|
	json.id notification.id
	json.icon iconos["#{notification.action}"]
	msg = "(#{notification.notifiable.nrc}) #{notification.actor.name} #{notification.actor.last_name} #{notification.action} ";
	if notification.notifiable_type == "StatusLoan"
		json.url paths["#{notification.notifiable_type}_#{notification.recipient.teacher}"]
		if notification.action == "wants to lend"
			msg += "$#{notification.notifiable.amount}"
		else
			msg += "the loan for $#{notification.notifiable.amount}"
		end
	else
		json.url paths[notification.notifiable_type]
		if notification.notifiable_type == "Offer" || notification.notifiable_type == "Auction"
			msg += "#{notification.notifiable.name}"
		else #if it is a transaction
			if notification.action == "transferred"
				msg += "you $#{notification.notifiable.amount}"
			elsif notification.action == "wants to transfer"
				msg += "#{notification.notifiable.user_to} $#{notification.notifiable.amount}"
			else
				msg += "the transaction from #{notification.recipient.name} to #{notification.secondactor.name}"
			end
		end
	end
	json.msg msg
end