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

end
