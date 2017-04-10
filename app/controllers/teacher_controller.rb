class TeacherController < ApplicationController
  
  def panel
  	respond_to do |format|
      format.html {render :layout => 'adminindex'}
    end
  end
  def editp
  	respond_to do |format|
      format.html {render :layout => 'admineditp'}
    end
  end
end
