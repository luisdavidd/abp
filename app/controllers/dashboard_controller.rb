class DashboardController < ApplicationController
  require 'csv'
  before_action :authenticate_user!
  layout 'panel_template'
  def delete_class
    @subjectsTD = SubjectNrc.where(subject_id:params[:id])
    @subjectsTD.each do |subjy|
      UserSubject.connection.execute("DELETE FROM user_subjects where subject_id="+subjy["nrc"].to_s+";")
      Auction.connection.execute("DELETE from auctions where nrc="+subjy["nrc"].to_s+";")
      Offer.where(nrc:subjy["nrc"].to_s).destroy_all
      Product.where(nrc:subjy["nrc"].to_s).destroy_all
      Transaction.where(nrc:subjy["nrc"].to_s).destroy_all
    end
    @subjectsTD.each do |subjy|
      SubjectNrc.connection.execute("DELETE FROM user_subjects where nrc="+subjy["nrc"].to_s+";")
    end
    Subject.connection.execute("DELETE FROM subjects where id='"+params[:id]+"';")
  end

  def delete_product
    Offer.connection.execute("DELETE FROM offers WHERE id='"+params[:id]+"';")
  end
  def delete_auction
    Auction.connection.execute("DELETE FROM auctions WHERE id='"+params[:id]+"';")
  end
  # Only for Professors
  def studentsHandler
    if current_user.teacher
      @users = User.where(teacher: '0')
      @subJ = Subject.connection.select_all("SELECT id,name,created_at from subjects order by name;")
      # render 'studentsHandler'
      nrcs = SubjectNrc.where(user_id: current_user.id) #subject.name and user.whatever
      query = "( nrc= " + nrcs.first.nrc.to_s
      nrcs.each do |nrc|
        query += " or nrc=" + nrc.nrc.to_s
      end
      query += ") and auth=0 and user_id!=#{current_user.id} and user_to!=#{current_user.id}"
      transactions = Transaction.where(query)
      @pendings = []
      transactions.each do |t|
        subj = Subject.where(id: SubjectNrc.where(nrc: t.nrc).first.subject_id).first
        user_to = User.where(id: t.user_to).first
        user_from = User.where(id: t.user_id).first
        @pendings.append({subject: subj.name, user_to: "#{user_to.name} #{user_to.last_name}", user_from: "#{user_from.name} #{user_from.last_name}", transaction: t})
      end
    
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

  def approve_reject_transfer
  if params[:flag]=='true'
    #puts 'Approve'
    t = Transaction.update(params[:id], auth: 2)
    UserSubject.connection.execute("Update user_subjects SET budget = budget-#{t.amount} WHERE(user_id=#{t.user_id} and subject_id=#{t.nrc});")
    UserSubject.connection.execute("Update user_subjects SET budget = budget+#{t.amount} WHERE(user_id=#{t.user_to} and subject_id=#{t.nrc});")
    User.connection.execute("Update users SET saldo=saldo-#{t.amount} WHERE id=#{t.user_id};")
    User.connection.execute("Update users SET saldo=saldo+#{t.amount} WHERE id=#{t.user_to};")
    Notification.create!({recipient_id: t.user_id, actor_id: current_user.id, action: "approved", secondactor_id: t.user_to, notifiable: t})
    Notification.create!({recipient_id: t.user_to, actor_id: t.user_id, action: "tranfer", notifiable: t, secondactor_id: t.user_to})
  else
    #puts 'Reject'
    t = Transaction.update(params[:id], auth: 1)
    Notification.create!({recipient_id: t.user_id, actor_id: current_user.id, action: "rejected", secondactor_id: t.user_to, notifiable: t})
    Notification.create!({recipient_id: t.user_to, actor_id: current_user.id, action: "rejected", secondactor_id: t.user_to, notifiable: t})
  end
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

  def deleteNRC
    nrc = params['nrc']
    SubjectNrc.where(nrc: nrc).destroy_all
    Auction.where(nrc: nrc).destroy_all
    Offer.where(nrc: nrc).destroy_all
    Product.where(nrc: nrc).destroy_all
    StatusLoan.where(nrc: nrc).destroy_all

    UserSubject.where(subject_id: nrc).find_each do |row|
      User.connection.execute("Update users SET saldo=saldo-"+row['budget'].to_s+" WHERE id="+row['user_id'].to_s+";")
    end

    UserSubject.where(subject_id: nrc).destroy_all

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
      products = Offer.connection.select_all("SELECT * from offers where (nrc="+params[:nrc].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND quantity>0 AND offer_type='"+tipo+"') order by id desc limit 1;")
    else
      products = Offer.connection.select_all("SELECT * from offers where (nrc="+params[:nrc].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND quantity>0 AND offer_type='"+tipo+"');")
      
    end
    students = Product.connection.select_all("SELECT * from products where nrc="+params[:nrc].to_s+";")
    render :json => {:products => products, :students => students}  
  end

  def auction_teacher
    @winnersG = Auction.connection.select_all("SELECT a.nrc,a.name,a.due_date,uf.name As Sname,uf.last_name from auctions as a,users uf where(a.auction_type='good' and a.winner = uf.id) order by a.updated_at desc")
    @winnersS = Auction.connection.select_all("SELECT a.nrc,a.name,a.due_date,uf.name As Sname,uf.last_name from auctions as a,users uf where(a.auction_type='service' and a.winner = uf.id) order by a.updated_at desc")
    @statusSt = []
    @statusGt = []
    @winnersG.each_with_index do |miniG,indexG|
      if(miniG['Sname']==nil)
        @statusGt.append({nID:indexG,status:'No one',class:'badge bg-gray'})
      else
        if(DateTime.now>=miniG['due_date'])
            @statusGt.append({nID:indexG,winner:miniG['Sname']+' '+miniG['last_name'],class:'badge bg-green'})
        else
            @statusGt.append({nID:indexG,winner:miniG['Sname']+' '+miniG['last_name'],class:'badge bg-yellow'})
        end
      end
    end
    @winnersS.each_with_index do |miniS,indexS|
      if(miniS['Sname']==nil)
        @statusSt.append({nID:indexS,status:'No one',class:'badge bg-gray'})
      else
        if(DateTime.now>=miniS['due_date'])
            @statusSt.append({nID:indexS,winner:miniS['Sname']+' '+miniS['last_name'],class:'badge bg-green'})
        else
            @statusSt.append({nID:indexS,winner:miniS['Sname']+' '+miniS['last_name'],class:'badge bg-yellow'})
        end
      end
    end
    # render :json => @winnersG
  end
  def auction_teacher_Handler
    if params[:auction_type]=="s"
      tipo = 'service'
    else
      tipo = 'good'
    end
    if params[:reload]=='true'
      products = Auction.connection.select_all("SELECT * from auctions where (nrc="+params[:nrc].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND auctioneers_number>0 AND auction_type='"+tipo+"') order by id desc limit 1;")
    else
      products = Auction.connection.select_all("SELECT * from auctions where (nrc="+params[:nrc].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND auctioneers_number>0 AND auction_type='"+tipo+"');")
      
    end
    students = Product.connection.select_all("SELECT * from products where nrc="+params[:nrc].to_s+";")
    
    render :json => {:products => products, :students => students}  
  end

  def getGoods_at_NRC
    groups = ProductGroup.connection.select_all("SELECT * from product_groups where nrc = "+params[:nrc].to_s)
    b_products = Product.connection.select_all("SELECT * from products where (nrc="+params[:nrc].to_s+" AND product_type='good');") #Bought products
    products = Product.connection.select_all("SELECT * from offers where (nrc="+params[:nrc].to_s+" AND offer_type='good');")
    render :json => {:products => products, :b_products => b_products, :groups => groups}
  end

  def getProducts_byGroup
    lab_items = Product.connection.select_all("SELECT o.* from offers as o, product_groups as pg, group_items as g where pg.id = "+params[:id].to_s+" AND g.group_id = pg.id AND g.product_id = o.id AND g.product_type = 2") 
    exam_items = Product.connection.select_all("SELECT o.* from offers as o, product_groups as pg, group_items as g where pg.id = "+params[:id].to_s+" AND g.group_id = pg.id AND g.product_id = o.id AND g.product_type = 1")
    row = ProductGroup.find(params[:id])
    render :json => {:lab_items => lab_items, :exam_items => exam_items, :lab_total => row['lab_total'], :exam_total => row['exam_total']}
  end

  def delete_group
    ProductGroup.find(params[:id]).destroy
    GroupItem.where(group_id: params[:id]).destroy_all
  end

  def new_product_group
    p = ProductGroup.create!({:group_name=>params[:name], :nrc =>params[:nrc], :exam_total =>params[:exam_total], :lab_total =>params[:lab_total]})
    id = p.id
    if params[:lab_items_list] != nil 
      for item in params[:lab_items_list]
        GroupItem.create!({:group_id=> id, :product_id =>item, :product_type =>2})
      end
    end
    if params[:exam_items_list] != nil 
      for item in params[:exam_items_list]
        GroupItem.create!({:group_id=> id, :product_id =>item, :product_type =>1})
      end
    end
  end

  def loans_teacher
    @pendings = StatusLoan.find_by_sql("SELECT u.name, u.last_name, s.name as subject, lt.type_name, us.budget, sl.*"+"
      FROM status_loans as sl, subject_nrcs as sn, users as u, subjects as s, loan_types as lt, user_subjects as us "+"
      where sn.nrc = sl.nrc AND us.subject_id = sl.nrc AND sl.loan_stat = 0 AND sl.student_id = u.id AND sl.student_id = us.user_id AND sn.subject_id = s.id AND sl.type_id = lt.id AND sn.user_id = "+current_user.id.to_s+" 
      order by sl.created_at ASC")
    
  end

  def approve_reject_loan
    if params[:flag]=='true'
      #puts 'Approve'
      loan = StatusLoan.update(params[:id], loan_stat: 2)
      StatusLoan.update(params[:id], starting_in: DateTime.now.next_week)
      Transaction.create!({:user_id=>current_user.id, :user_to =>params[:student_id], :amount =>params[:amount], :observations =>params[:type_name], :nrc =>params[:nrc]})
      UserSubject.connection.execute("Update user_subjects SET budget = budget+"+params[:amount]+" WHERE(user_id="+params[:student_id]+" and subject_id="+params[:nrc]+");")
      User.connection.execute("Update users SET saldo=saldo+"+params[:amount]+" WHERE id="+params[:student_id]+";")
      Notification.create!({recipient_id: params[:student_id], actor_id: current_user.id, action: "approved", notifiable: loan, secondactor_id: params[:student_id]})
    else
      #puts 'Reject'
      loan = StatusLoan.update(params[:id], loan_stat: 1)
      Notification.create!({recipient_id: params[:student_id], actor_id: current_user.id, action: "rejected", notifiable: loan, secondactor_id: params[:student_id]})
    end
  end

  def subject_loans
    loans = StatusLoan.find_by_sql("SELECT lt.type_name, lt.fees, sl.* FROM status_loans as sl, loan_types as lt where sl.type_id = lt.id AND sl.nrc = "+params['nrc'].to_s+" AND sl.student_id = "+params['id'].to_s)
    render :json => {:loans => loans} 
  end

  # For everyone:
  def notifications
    notifications = Notification.where(recipient_id: current_user.id)
    paths = {"Offer" => "shopping_student",
    "Auction" => "auction_student",
    "Transaction" => "historicalTransactions",
    "StatusLoan_true" => "loans_teacher",
    "StatusLoan_false" => "loans_student"
    }
    @info_array = []
    notifications.each do |notification|
      msg = "#{notification.actor.name} #{notification.actor.last_name} #{notification.action} ";
      if notification.notifiable_type == "StatusLoan"
        url = paths["#{notification.notifiable_type}_#{notification.recipient.teacher}"]
        if notification.action == "wants to lend"
          msg += "#{notification.notifiable.amount} bacs"
        else
          msg += "the loan for #{notification.notifiable.amount} bacs"
        end
      else
        url = paths[notification.notifiable_type]
        if notification.notifiable_type == "Offer" || notification.notifiable_type == "Auction"
          msg += "#{notification.notifiable.name}"
        else #if it is transaction
          if notification.action == "tranfer"
            msg += "you #{notification.notifiable.amount} bacs"
          elsif notification.action == "wants to tranfer"
            msg += "#{notification.notifiable.user_to} #{notification.notifiable.amount} bacs"
            # No funcionara bien porque user_to es una id
          else
            msg += "the transaction from #{notification.recipient.name} #{notification.recipient.last_name} to #{notification.secondactor.name} #{notification.secondactor.last_name} for #{notification.notifiable.amount} bacs"
          end
        end
      end
      @info_array.append({:nrc => notification.notifiable.nrc,:date => notification.created_at, :msg => msg, :url => url})
    end
  end

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
      @tSaldo = UserSubject.connection.select_all("SELECT SUM(budget) As totalBudget from user_subjects where (user_id ="+current_user.id.to_s+");")
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
    begin
      if @user.update(user_params)
        # Sign in the user by passing validation in case their password changed
        @user = User.find(current_user.id)
        orqix = Cloudinary::Uploader.upload(File.join(File.expand_path("~/Documents"),@user.avatar_file_name))
        @user.update({:avatar_file_name=>orqix["url"].to_s})
        redirect_to dashboard_panel_path
        
      else
        respond_to do |format|
        format.html { redirect_to dashboard_editp_path, alert: 'Ha ocurrido un error al actualizar tu perfil. Intenta de nuevo.' }
        end
      end
    rescue
      respond_to do |format|
        format.html { redirect_to dashboard_editp_path, alert: 'Extensión de archivo no valida. Intente de nuevo. Solo archivos JPG.' }
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
      t = Transaction.create!({:user_id=>current_user.id, :user_to =>user, :amount =>params[:amount], :observations =>params[:observations], :nrc =>params[:nrc], :auth => 1})
      UserSubject.connection.execute("Update user_subjects SET budget = budget+"+params[:amount]+" WHERE(user_id="+user+" and subject_id="+params[:nrc]+");")
      User.connection.execute("Update users SET saldo=saldo+"+params[:amount]+" WHERE id="+user+";")
      Notification.create!({recipient_id: user, actor_id: current_user.id, action: "transfer", notifiable: t, secondactor_id: user})
      #Ojoooo esta transferencia seguro tiene mensaje raro
    end
  end

  def historicalTransactions
    @dTransaction = Transaction.connection.execute("SELECT uF.name,uF.last_name, uT.name,uT.last_name, t.amount, t.observations, t.created_at FROM users as uF, users uT, transactions as t where (t.user_id="+current_user.id.to_s+" or t.user_to="+current_user.id.to_s+") and (t.user_to=uT.id and t.user_id=uF.id) and t.auth !=0;")
    #render :json => @dTransaction
  end

  def newProduct
    if params[:offer_type]=='true'
      tipo = 'service'
    else
      tipo = 'good'
    end
    students = UserSubject.connection.select_all("SELECT user_id FROM user_subjects where subject_id="+params[:nrc]+";")
    producto = Offer.create!({:user_id=>current_user.id,:name =>params[:name], :quantity =>params[:quantity], :price =>params[:price], :due_date =>params[:due], :nrc =>params[:nrc], :offer_type => tipo})
    students.each do |student|
      Notification.create!({recipient_id: student["user_id"], actor_id: current_user.id, action: "added", notifiable: producto, secondactor_id: student["user_id"]})
    end
  end

  def newAuction
    if params[:auction_type]=='true'
      tipo = 'service'
    else
      tipo = 'good'
    end
      Auction.create!({:user_id=>current_user.id,:name =>params[:name], :auctioneers_number=>params[:quantity], :price =>params[:price], :due_date =>params[:due], :nrc =>params[:nrc], :auction_type => tipo})
  end

  def getBudget
    puts "Soy nrc",params[:nrc]
    bget = UserSubject.connection.select_all("SELECT budget from user_subjects where(user_id="+current_user.id.to_s+" and subject_id = '"+params[:nrc]+"');")
    render :json => bget[0]['budget']
  end

  def shopping_student
    @SIPG = Product.connection.select_all("SELECT elemento,nrc,created_at from products where (user_id="+current_user.id.to_s+" and product_type='good') order by created_at desc;")
    @SIPS = Product.connection.select_all("SELECT elemento,nrc,created_at from products where (user_id="+current_user.id.to_s+" and product_type = 'service') order by created_at desc;")
    @NRCShop = UserSubject.connection.select_all("SELECT subject_id,budget from user_subjects where user_id = "+current_user.id.to_s+";") 
    @budget=UserSubject.connection.select_all("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
    @shoptG = []
    @shoptS = []
    @NRCShop.each do |nrce|
      tempG = Offer.connection.select_all("SELECT id,name,price,due_date,quantity,nrc from offers where (nrc="+nrce['subject_id'].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND quantity>0 and offer_type='good');")
      tempS = Offer.connection.select_all("SELECT id,name,price,due_date,quantity,nrc from offers where (nrc="+nrce['subject_id'].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND quantity>0 and offer_type='service');")
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

  def auction_student
    @NRCIN = UserSubject.connection.select_all("SELECT subject_id from user_subjects where user_id = "+current_user.id.to_s+";")
    @NRCIN.each do |nrce|
      @SIPG = Auction.connection.select_all("SELECT id,name,nrc,due_date,winner,participants from auctions where (auction_type='good' and nrc="+nrce['subject_id'].to_s+") order by updated_at desc;")
      @SIPS = Auction.connection.select_all("SELECT id,name,nrc,due_date,winner,participants from auctions where (auction_type = 'service' and nrc="+nrce['subject_id'].to_s+") order by updated_at desc;")
    
    end
    @statusG= []
    @statusS= []
    @participantsG = []
    @participantsS = []
    @SIPG.each_with_index do  |miniG,indexG|
      if(not miniG['participants']== nil)
        @participantsG.append(miniG['participants'].split(";"))
        @participantsG[indexG]=@participantsG[indexG].uniq
      end
    end
    @SIPS.each_with_index do  |miniS,indexS|
      if(not miniS['participants']== nil) 
        @participantsS.append(miniS['participants'].split(";"))
        @participantsS[indexS]=@participantsS[indexS].uniq      
      else
      end

    end

    @SIPG.each_with_index do |miniG,indexG|
      @participantsG[indexG].delete(nil)
      if(miniG['winner']==nil or (not (@participantsG[indexG].include?(current_user.id.to_s))))
        @statusG.append({nID:indexG,status:'Not in',class:'badge bg-gray'})
      else
        if(DateTime.now>=miniG['due_date'])
          if(miniG['winner']==current_user.id)
            @statusG.append({nID:indexG,status:'Won',class:'badge bg-green'})
          else
            @statusG.append({nID:indexG,status:'Lost',class:'badge bg-red'})
          end
        else
          if(miniG['winner']==current_user.id)
            @statusG.append({nID:indexG,status:'Winning',class:'badge bg-yellow'})
          else
            @statusG.append({nID:indexG,status:'Losing',class:'badge bg-red'})
          end
        end
      end
    end
    @SIPS.each_with_index do |miniS,indexS|
      @participantsS[indexS].delete(nil)
      if(miniS['winner']==nil or (not (@participantsS[indexS].include?(current_user.id.to_s))))
        @statusS.append({nID:indexS,status:'Not in',class:'badge bg-gray'})
      else
        if(DateTime.now>=miniS['due_date'])
          if(miniS['winner']==current_user.id)
            @statusS.append({nID:indexS,status:'Won',class:'badge bg-green'})
          else
            @statusS.append({nID:indexS,status:'Lost',class:'badge bg-red'})
          end
        else
          if(miniS['winner']==current_user.id)
            @statusS.append({nID:indexS,status:'Winning',class:'badge bg-yellow'})
          else
            @statusS.append({nID:indexS,status:'Losing',class:'badge bg-red'})
          end
        end
      end
    end

    @NRCShop = UserSubject.connection.select_all("SELECT subject_id,budget from user_subjects where user_id = "+current_user.id.to_s+";") 
    @budget=UserSubject.connection.select_all("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
    @shoptG = []
    @shoptS = []
    @NRCShop.each do |nrce|
      tempG = Auction.connection.select_all("SELECT id,name,price,due_date,auctioneers_number,nrc from auctions where (nrc="+nrce['subject_id'].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND auctioneers_number>0 and auction_type='good');")
      tempS = Auction.connection.select_all("SELECT id,name,price,due_date,auctioneers_number,nrc from auctions where (nrc="+nrce['subject_id'].to_s+" AND due_date>=(NOW()-INTERVAL 5 HOUR) AND auctioneers_number>0 and auction_type='service');")
      if tempG.blank?
      else
        @shoptG.append(tempG)
      end
      if tempS.blank?
      else
        @shoptS.append(tempS)
      end
      
    end
    # render :json => @participantsG
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

  def bidAuction
    @fAuction = Auction.select("winner").where('id'=>params[:auction_id])
    if(@fAuction.count==0)
      Auction.connection.execute("Update auctions SET price="+params[:newPrice]+",winner="+current_user.id.to_s+",participants="+current_user.id.to_s+" where(nrc="+params[:auction_nrc]+" and id="+params[:auction_id]+");")
      UserSubject.connection.execute("Update user_subjects SET budget=budget-"+params[:newPrice]+" where (subject_id="+params[:auction_nrc]+" and user_id="+current_user.id.to_s+"); ")
    else
      UserSubject.connection.execute("Update user_subjects SET budget=budget+"+params[:oldPrice]+" where (subject_id="+params[:auction_nrc]+" and user_id="+@fAuction[0]['winner'].to_s+"); ")
      Auction.connection.execute("Update auctions SET price="+params[:newPrice]+",winner="+current_user.id.to_s+",participants=CONCAT(participants,';',"+current_user.id.to_s+") where(nrc="+params[:auction_nrc]+" and id="+params[:auction_id]+");")
      UserSubject.connection.execute("Update user_subjects SET budget=budget-"+params[:newPrice]+" where (subject_id="+params[:auction_nrc]+" and user_id="+current_user.id.to_s+"); ")
    end
  end

  def newTransactionStudent
    nrc = UserSubject.connection.select_all("SELECT n.nrc from user_subjects as u, subjects as s, subject_nrcs as n 
      where(u.user_id="+current_user.id.to_s+" and n.nrc = u.subject_id and n.subject_id = s.id and s.name = '"+params[:subject]+"');")
    nrc_u = nrc[0]['nrc'].to_s
    params[:student].each_with_index do |user, i|
      t = Transaction.create!({:user_id=>current_user.id, :user_to =>user, :amount =>params[:amount], :observations =>params[:observations], :nrc =>params[:nrc]})
      teacher = SubjectNrc.where(nrc: t.nrc).first.user_id
      Notification.create!({recipient_id: teacher, actor_id: current_user.id, action: "wants to tranfer", secondactor_id: user, notifiable: t})
      Notification.create!({recipient_id: user, actor_id: current_user.id, action: "wants to tranfer", secondactor_id: user, notifiable: t})
      UserMailer.transfer_request(User.where(id: teacher).first, t).deliver
    end
  end

  def transferStudent
    budgetsQuery=UserSubject.connection.select_all("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
    std_budgets = []
    for row in budgetsQuery
      std_budgets.append(row['budget'])
    end

    classes = Subject.connection.select_all("SELECT s.id, s.name, s.user_id from subjects as s, user_subjects as u, 
      subject_nrcs as n where u.user_id="+current_user.id.to_s+" and u.subject_id=n.nrc and n.subject_id = s.id;")
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
          #std_names.append([student["name"],student["last_name"],student["email"],student["budget"],student["codigo"]])
          std_names.append([student["name"],student["last_name"],student["email"],student["codigo"]])
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

    @budgets = std_budgets
    
    render :json => {:classes => @classes, :NRCs => @NRCs, :students_names => @students_names, :students_ids => @students_ids, :student_budgets => @budgets}
    
  end

  def loans_student
    @budget=UserSubject.connection.select_all("SELECT su.name,suser.subject_id,suser.budget from subjects as su,user_subjects suser,subject_nrcs snrc where (snrc.subject_id= su.id and suser.user_id="+current_user.id.to_s+" and suser.subject_id = snrc.nrc);")
    @loans = []
    @loan_types = Hash.new
    loan_interest = Hash.new
    @loan_fees = Hash.new

    LoanType.find_each do |row|
      @loans.append(row)
      @loan_types[row['id']] = row['type_name']
      loan_interest[row['id']] = row['interest']
      @loan_fees[row['id']] = row['fees']
    end


    @loans_status = []
    @payment = []
    StatusLoan.where("student_id = "+current_user.id.to_s).find_each do |row|
      @loans_status.append(row)
      if row['loan_stat'] == 2
        itr = loan_interest[row['type_id']]/100.0
        amt = row['amount']
        feeVal = row['next_payment']
        n = @loan_fees[row['type_id']]-row['current_fee']
        p = (feeVal*(((1+itr)**n)-1)/(itr*((1+itr)**n))).round
        @payment.append(p)
      else
        @payment.append(0)
      end
    end
    @loan_status_label = {0 => {"Status" => "Pending", "Class" => "badge bg-yellow"}, 1 => {"Status" => "Rejected", "Class" => "badge bg-red"}, 2 => {"Status" => "Approved", "Class" => "badge bg-green"}, 3 => {"Status" => "Finished", "Class" => "badge bg-gray"}}

  end

  def newLoan
    row = LoanType.find(params[:loan_id])
    itr = row['interest'].to_i/100.0
    puts itr
    n = row['fees'].to_i
    puts n
    feeVal= (params[:amount].to_i*(itr*((1+itr)**n))/(((1+itr)**n)-1)).ceil
    puts feeVal
    loan = StatusLoan.create!({:student_id=>current_user.id, :nrc=>params[:nrc], :loan_stat=>0,:type_id =>params[:loan_id], :amount =>params[:amount], :next_payment => feeVal})
    teacher = SubjectNrc.where(nrc: loan.nrc).first.user_id
    Notification.create!({recipient_id: teacher, actor_id: current_user.id, action: "wants to lend", secondactor_id: teacher, notifiable: loan})
  end

  def payAll_Loan
    status_row = StatusLoan.find(params[:id])
    loan_row = LoanType.find(status_row['type_id'])
    feeVal = status_row['next_payment'].to_i
    itr = loan_row['interest']/100.0
    n = loan_row['fees']-status_row['current_fee']
    pay = (feeVal*(((1+itr)**n)-1)/(itr*((1+itr)**n))).round
    puts pay

    teacher = SubjectNrc.joins("INNER JOIN status_loans ON status_loans.id = "+status_row['id'].to_s+" AND status_loans.nrc = subject_nrcs.nrc")
    puts teacher[0]['user_id']
    
    Transaction.create!({:user_id=>current_user.id, :user_to =>teacher[0]['user_id'].to_i, :amount => pay, :observations =>"Pay All: "+loan_row['type_name'].to_s, :nrc =>status_row['nrc'].to_i})
    UserSubject.connection.execute("Update user_subjects SET budget = budget-"+pay.to_s+" WHERE(user_id="+current_user.id.to_s+" and subject_id="+status_row['nrc'].to_s+");")
    User.connection.execute("Update users SET saldo=saldo-"+pay.to_s+" WHERE id="+current_user.id.to_s+";")

    StatusLoan.update(status_row['id'], loan_stat: 3)
    StatusLoan.update(status_row['id'], current_fee: loan_row['fees'])
    Notification.create!({recipient_id: teacher, actor_id: current_user.id, secondactor_id: teacher, action: "paid", notifiable: loan})
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
