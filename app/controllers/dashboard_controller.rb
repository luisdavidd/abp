class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout 'panel_template'

  # Only for Professors
  def studentsHandler
    if current_user.teacher
      @users = User.where(teacher: '0')
      render 'studentsHandler'
    else
      render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found 
    end
  end

  def newStudents
    #generated_pass = Devise.friendly_token.first(4)
    generated_pass = rand(9999).to_s.center(4, rand(9).to_s)
    @user = User.create!({:name=>params[:name], :last_name =>params[:last_name], :email =>params[:email], :saldo =>params[:saldo], :codigo =>params[:codigo], :password => generated_pass})
    UserMailer.welcome_email(@user).deliver
  end

  def editStudents
    @users = User.where(teacher: '0')
    render :json => @users
  end

  def editClasses
    #@out = SubjectNrc.joins(Subject.name) #funciona pero no une nada
    @out = SubjectNrc.connection.execute("SELECT s.id, s.name, n.id, n.nrc FROM subject_nrcs as n, subjects as s WHERE n.subject_id = s.id;")
    @classes_name = Subject.all()
    render :json => {:names => @classes_name, :tabla => @out }
  end

  def addClasses
    class_nrc = SubjectNrc.new(:subject_id => 1)
    class_nrc.save()
    render :json => class_nrc
  end

  def update_class
   @class =  SubjectNrc.where({ :id => params[:index]})
   @class.update({params[:column] => params[:new]})
   render :json => @class
  end

  def update
   @user =  User.where({ :id => params[:index]})
   @user.update({params[:column] => params[:new]})
   render :json => @user
  end

  # For everyone:
  def panel
    if current_user.teacher
      render 'teacher'
    else
      render 'student'
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