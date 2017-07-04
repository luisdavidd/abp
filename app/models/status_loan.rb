class StatusLoan < ApplicationRecord
	
	def self.loans_payment
		types = Hash.new 
		LoanType.find_each do |type|
			types[type['id']] = type['fees']
		end

		StatusLoan.where("loan_stat = 2 AND starting_in <= ?", Time.now).find_each do |loan|
			UserSubject.connection.execute("Update user_subjects SET budget = budget-"+loan['next_payment'].to_s+" WHERE(user_id="+loan['student_id'].to_s+" and subject_id="+loan['nrc'].to_s+");")
    		User.connection.execute("Update users SET saldo=saldo-"+loan['next_payment'].to_s+" WHERE id="+loan['student_id'].to_s+";")
    		StatusLoan.connection.execute("Update status_loans SET current_fee = current_fee+1 where id = "+loan['id'].to_s)
    		if(loan['current_fee']+1 >= types[loan['type_id']])
    			StatusLoan.connection.execute("Update status_loans SET loan_stat = 3 where id = "+loan['id'].to_s)
    		end
		end
	end
end
