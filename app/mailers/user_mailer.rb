class UserMailer < ApplicationMailer
	def welcome_email(user)
	    @user = user
	    @url  = 'http://localhost:3000/users/sign_in'
	    mail(to: @user.email, subject: 'Welcome to ABP')
  	end
end
