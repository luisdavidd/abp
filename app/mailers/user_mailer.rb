class UserMailer < ApplicationMailer
	def welcome_email(user)
	    @user = user
	    @url  = 'http://acssolutions.ddns.net/users/sign_in'
	    mail(to: @user.email, subject: 'Welcome to ABP')
  	end

  	def transfer_request(user, t)
	    @user = user	    
	    @approve_url = "acssolutions.ddns.net/dashboard/approve_reject_transfer?flag=true&id="+t.id.to_s
	    @reject_url = "acssolutions.ddns.net/dashboard/approve_reject_transfer?flag=false&id="+t.id.to_s
	    @url_normal = "acssolutions.ddns.net/dashboard/studentsHandler"
	    subj = Subject.where(id: SubjectNrc.where(nrc: t.nrc).first.subject_id).first
        user_to = User.where(id: t.user_to).first
        user_from = User.where(id: t.user_id).first
        @pendings = {subject: subj.name, user_to: "#{user_to.name} #{user_to.last_name}", user_from: "#{user_from.name} #{user_from.last_name}", transaction: t}
        mail(to: @user.email, subject: 'New Transaction Request')
  	end
end
