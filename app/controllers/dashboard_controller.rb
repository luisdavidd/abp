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

  def update_image
    @user = User.find(current_user.id)
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
       
      redirect_to dashboard_panel_path
    else
      respond_to do |format|
        format.html { redirect_to dashboard_editp_path, alert: 'Ha ocurrido un error al actualizar tu perfil. Intenta de nuevo.' }
      end
    end
  end

  def update_skin
    @user = User.find(current_user.id)
    @user.update({:skin => params[:skin]}) 
    @skins = params[:skin]
    render :json => @user
  end
  
  def get_myskin
    @skin = User.select("skin").where({:id=>current_user.id})
    render :json =>@skin
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update(user_pass_params)  
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true
      redirect_to dashboard_panel_path
    end
  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:avatar)
  end

  def user_pass_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end