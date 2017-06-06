class DashboardController < ApplicationController
  require 'csv'
  before_action :authenticate_user!
  layout 'panel_template'

  def delete_product
    Offer.connection.execute("DELETE FROM offers WHERE id='"+params[:id]+"';")
  end
  # Only for Professors
  def studentsHandler
    if current_user.teacher
      @users = User.where(teacher: '0')
      @subJ = Subject.connection.select_all("SELECT name,created_at from subjects order by name;")
      # render 'studentsHandler'
    else
      render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found 
    end
  end

  def newStudents
    generated_pass = rand(9999).to_s.center(4, rand(9).to_s)
    @user = User.create!({:name=>params[:name], :last_name =>params[:last_name], :email =>params[:email], :saldo =>params[:saldo], :codigo =>params[:codigo], :password => generated_pass})
  end

  def createnewClass
    @verifEC = Subject.connection.select_all("SELECT LCASE(name) from subjects where (LCASE(name)='"+params[:className].to_s.downcase+"');")
    @ccCreate = 0
    if(@verifEC.count == 0)
      @ccCreate = Subject.connection.select_all("INSERT INTO subjects (name,user_id) VALUES('"+params[:className].to_s+"',"+current_user.id.to_s+");")
    else
      
    end
    render :json => @ccCreate
  end

  def editStudents
    @users = User.where(teacher: '0')
    render :json => @users
  end

  def editClasses
    #@out = SubjectNrc.joins(Subject.name) #funciona pero no une nada
    @out = SubjectNrc.connection.execute("SELECT s.id, s.name, n.id, n.nrc FROM subject_nrcs as n, subjects as s WHERE (n.subject_id = s.id and n.user_id = "+current_user.id.to_s+" and n.user_id = s.user_id) ;")
    @classes_name = Subject.where("user_id="+current_user.id.to_s+"")
    render :json => {:names => @classes_name, :tabla => @out }
  end

  def addClasses
    # subir todo lo que se ingresa en el formulario
    class_nrc = SubjectNrc.new(:subject_id => params[:subject_id], :nrc => params[:NRC], :user_id => current_user.id)
    nrcindb = SubjectNrc.where({nrc: params[:NRC]})
    if(nrcindb.count==1)
      #nrcindb.update({:nrc => params[:NRC]})

    else
      class_nrc.save()
    end
    render :json => class_nrc

  end

  def update_class
    @class =  SubjectNrc.where({ :id => params[:index]})
    @user_class = UserSubject.connection.execute("UPDATE `user_subjects` SET `subject_id` = "+params[:new]+" WHERE `subject_id` = "+@class.first.nrc.to_s+";")
    @class.update({params[:column] => params[:new]})
   
  end

  def update
   @user =  User.where({ :id => params[:index]})
   @user.update({params[:column] => params[:new]})
   render :json => @user
  end

  def shopping_teacher_Handler
    if params[:offer_type]=="s"
      tipo = 'service'
    else
      tipo = 'good'
    end
    if params[:reload]=='true'
      products = Offer.connection.select_all("SELECT * from offers where (nrc="+params[:nrc].to_s+" AND due_date>=CURDATE() AND quantity>0 AND offer_type='"+tipo+"') order by id desc limit 1;")
    else
      products = Offer.connection.select_all("SELECT * from offers where (nrc="+params[:nrc].to_s+" AND due_date>=CURDATE() AND quantity>0 AND offer_type='"+tipo+"');")
      
    end
    students = Product.connection.select_all("SELECT * from products where nrc="+params[:nrc].to_s+";")
    render :json => {:products => products, :students => students}  
  end

  # For everyone:
  def panel
    if current_user.teacher
      @count = SubjectNrc.where(:user_id => current_user.id).count
      @numbers = User.where(:teacher=>0).count
      @enrolled = SubjectNrc.connection.execute("SELECT su.name,snrc.nrc from subjects as su,users uf,subject_nrcs snrc where (snrc.subject_id= su.id and snrc.user_id="+current_user.id.to_s+" and snrc.user_id=uf.id);")
      @budget_adj=Transaction.connection.execute("SELECT nrc,WEEK(created_at),SUM(amount) AS Budgetperclass FROM transactions where (user_id="+current_user.id.to_s+" or user_to="+current_user.id.to_s+") group by nrc,WEEK(created_at);")
      
      render 'teacher'
      
    else
      @enrolled=UserSubject.connection.execute("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
      @notifs = Transaction.connection.execute("SELECT COUNT(*) from transactions where (user_id="+current_user.id.to_s+" or user_to="+current_user.id.to_s+");")
      @budget_adj=Transaction.connection.execute("SELECT nrc,WEEK(created_at),SUM(amount) AS Budgetperclass FROM transactions where (user_id="+current_user.id.to_s+" or user_to="+current_user.id.to_s+") group by nrc,WEEK(created_at);")
      
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
  
  def import
    file = params[:file]
    nrc = params[:nrc]
    CSV.foreach(file.path, headers: true) do |row|
      student_hash = row.to_hash # exclude the price field
      student = User.where({email: student_hash["Email"]+'@uninorte.edu.co'})
      if(student.count == 1)
        studentinnrc = UserSubject.connection.execute("SELECT uf.name,uf.last_name from users as uf, user_subjects usub where (usub.user_id = "+student.first.id.to_s+" and usub.user_id = uf.id and usub.subject_id="+nrc.to_s+");")
        student.first.update_attributes(:name=>student_hash["Name"],:last_name=>student_hash["Last name"],:email =>student_hash["Email"]+'@uninorte.edu.co',:codigo=>student_hash["Codigo"])
        if(studentinnrc.count==1)
          puts("")
        else
          user_subject = UserSubject.connection.execute("INSERT INTO user_subjects (user_id,subject_id,created_at,updated_at) VALUES("+student.first.id.to_s+","+nrc.to_s+",now(),now())")
        end
      else
        generated_pass = rand(9999).to_s.center(4, rand(9).to_s)
        @user = User.create!({:name=>student_hash["Name"], :last_name =>student_hash["Last name"], :email =>student_hash["Email"]+'@uninorte.edu.co', :saldo =>'0', :codigo =>student_hash["Codigo"], :password => generated_pass})
        user_subject = UserSubject.connection.execute("INSERT INTO user_subjects (user_id,subject_id,created_at,updated_at) VALUES("+@user.id.to_s+","+nrc.to_s+",now(),now())")
        
        flash[:notice] = "Users successfully created."
        #UserMailer.welcome_email(@user).deliver
      end # end if !product.nil?
    end # end CSV.foreach
  end
  def student_historics
    @users = User.where(teacher: '0').order('name')
    
  end

  def userTransactions
    #@trans_user =  Transaction.where({ :user_id => })
    @trans_user = Transaction.connection.execute("SELECT uF.name,uF.last_name, uT.name,uT.last_name, t.amount, t.observations, t.created_at FROM users as uF, users uT, transactions as t where (t.user_id="+params[:id]+" or t.user_to="+params[:id]+") and (t.user_to=uT.id and t.user_id=uF.id) and t.nrc="+params[:nrcito]+";")
    render :json => @trans_user
  end

  def transfer
    classes = Subject.connection.select_all("SELECT * from subjects where user_id="+current_user.id.to_s+";")
    @data = Hash.new
    i = 0
    classes_array = []
    nrc_array = []
    students_array = []
    students_id_array = []
    for clase in classes
      #class_name = clase.name
      classes_array.append(clase['name'])
      nrcs = SubjectNrc.select("id, nrc").where('subject_id' => clase['id'])
      nrc_names = []
      std_sub_array = []
      std_ids_sub_array = []

      for nrc in nrcs
        #nrc_ids.append(nrc.id)
        nrc_names.append(nrc.nrc)
        students = UserSubject.connection.select_all("SELECT u.id, u.name, u.last_name, u.email, s.budget, u.codigo FROM users as u, user_subjects as s WHERE s.subject_id = "+nrc.nrc.to_s+" and u.id=s.user_id;")
        std_names = []
        std_ids = []
        for student in students
          std_ids.append(student["id"])
          std_names.append([student["name"],student["last_name"],student["email"],student["budget"],student["codigo"]])
        end
        std_sub_array.append(std_names)
        std_ids_sub_array.append(std_ids)
      end
      nrc_array.append(nrc_names)
      students_array.append(std_sub_array)
      students_id_array.append(std_ids_sub_array)
      #nrcs = SubjectNrc.connection.execute("SELECT s.id, s.name, n.id, n.nrc FROM subject_nrcs as n, subjects as s WHERE n.subject_id = s.id;")
    end
    @classes = classes_array
    @NRCs = nrc_array
    @students_names = students_array
    @students_ids = students_id_array
    
    render :json => {:classes => @classes, :NRCs => @NRCs, :students_names => @students_names, :students_ids => @students_ids}
    
  end


 def newTransaction
    params[:student].each_with_index do |user, i|
    #user = params[:student]
      Transaction.create!({:user_id=>current_user.id, :user_to =>user, :amount =>params[:amount], :observations =>params[:observations], :nrc =>params[:nrc]})
      UserSubject.connection.execute("Update user_subjects SET budget = budget+"+params[:amount]+" WHERE(user_id="+user+" and subject_id="+params[:nrc]+");")
      User.connection.execute("Update users SET saldo=saldo+"+params[:amount]+" WHERE id="+user+";")
    end
  end

  def historicalTransactions   
    @dTransaction = Transaction.connection.execute("SELECT uF.name,uF.last_name, uT.name,uT.last_name, t.amount, t.observations, t.created_at FROM users as uF, users uT, transactions as t where (t.user_id="+current_user.id.to_s+" or t.user_to="+current_user.id.to_s+") and (t.user_to=uT.id and t.user_id=uF.id);")
    #render :json => @dTransaction
  end

  def newProduct
    if params[:offer_type]=='true'
      tipo = 'service'
    else
      tipo = 'good'
    end
      Offer.create!({:user_id=>current_user.id,:name =>params[:name], :quantity =>params[:quantity], :price =>params[:price], :due_date =>params[:due], :nrc =>params[:nrc], :offer_type => tipo})
  end

  def getBudget
    puts "Soy nrc",params[:nrc]
    bget = UserSubject.connection.select_all("SELECT budget from user_subjects where(user_id="+current_user.id.to_s+" and subject_id = '"+params[:nrc]+"');")
    render :json => bget[0]['budget']
  end

  def shopping_student
    @SIPG = Product.connection.select_all("SELECT elemento,nrc,created_at from products where (user_id="+current_user.id.to_s+" and product_type='good');")
    @SIPS = Product.connection.select_all("SELECT elemento,nrc,created_at from products where (user_id="+current_user.id.to_s+" and product_type = 'service');")
    @NRCShop = UserSubject.connection.select_all("SELECT subject_id,budget from user_subjects where user_id = "+current_user.id.to_s+";") 
    @budget=UserSubject.connection.select_all("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
    @shoptG = []
    @shoptS = []
    @NRCShop.each do |nrce|
      tempG = Offer.connection.select_all("SELECT id,name,price,due_date,quantity,nrc from offers where (nrc="+nrce['subject_id'].to_s+" AND due_date>=CURDATE() AND quantity>0 and offer_type='good');")
      tempS = Offer.connection.select_all("SELECT id,name,price,due_date,quantity,nrc from offers where (nrc="+nrce['subject_id'].to_s+" AND due_date>=CURDATE() AND quantity>0 and offer_type='service');")
      if tempG.blank?
      else
        @shoptG.append(tempG)
      end
      if tempS.blank?
      else
        @shoptS.append(tempS)
      end
      
    end
    # render :json => @SIP[0]['elemento']
  end

  def buyProduct
  	product = Offer.connection.select_all("SELECT * from offers where id="+params[:product_id]+";").first
    observation = product['name']
    amount = product['price'].to_s
    verifAd = Product.connection.select_all("SELECT offer_id from products where(user_id="+current_user.id.to_s+" and offer_id="+product['id'].to_s+");")
    if(verifAd.count == 0)
      @buy = Transaction.create!({:user_id=>current_user.id, :user_to =>product['user_id'], :amount =>amount, :observations =>observation, :nrc => product['nrc']})
      if @buy.save
        UserSubject.connection.execute("Update user_subjects SET budget = budget-"+amount+" WHERE(user_id="+current_user.id.to_s+" and subject_id="+product['nrc'].to_s+");")
        User.connection.execute("Update users SET saldo=saldo-"+amount+" WHERE id="+current_user.id.to_s+";")
        Product.create!({:offer_id=>product['id'],:user_id=>current_user.id,:elemento =>observation,:nrc=>product['nrc'],:product_type =>product['offer_type']})
        Offer.connection.execute("Update offers SET quantity=quantity-1 where id="+params[:product_id]+";")
      end
      flash[:success] = "Product succesfully bought!!!"
    else
      flash[:error] = "Sorry... Product already bought!!!"
      
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