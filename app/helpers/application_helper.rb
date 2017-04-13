module ApplicationHelper
  
  def flash_class(level)
      case level
          when 'notice' then "alert alert-dismissable alert-info"
          when 'success' then "alert alert-dismissable alert-success"
          when 'error' then "alert alert-dismissable alert-danger"
          when 'alert' then "alert alert-dismissable alert-danger"
      end
  end
  
  def alert_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end