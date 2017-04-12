class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout 'panel_template'
  def panel
    if current_user.teacher
      render 'teacher'
    else
      render 'student'
    end
  end

  def editp
    #respond_to do |format|
    #  format.html {render :layout => 'admineditp'}
    #end
  end

  def editStudent
    if current_user.teacher
      @users = User.where(teacher: '0')
      render 'editStudent'
    else
      render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found 
    end
  end

  def update
   @user =  User.where({ :id => params[:index]})
   @user.update({params[:column] => params[:new]})
   render :json => @user
   
  end


end