module ApplicationHelper

  DEFAULT_NO_ANSWER = "No answer yet"

	#returns the full title on a per-page basis
	def full_title(page_title)
		base_title = CONFIG[:title] || "Ruby on Rails Template"
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end

  #returns the Display Name of the application
  def app_display_name
    CONFIG[:display_name] || "Multigroup Events" 
  end

	#return class name for flash message based on type
  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success" # Green
      when :error
        "alert-danger" # Red
      when :alert
        "alert-warning" # Yellow
      when :notice
        "alert-info" # Blue
      else
        flash_type.to_s
    end
  end

  def display_no_answer(msg=DEFAULT_NO_ANSWER)
    content_tag(:span, msg, class: "no-answer")
  end

  def show_answer(answer)
    answer.blank? ? display_no_answer : answer
  end

  def edit_object_link(obj, name=nil)
    name ||= obj.class.name.humanize
    label = "Edit"
    if obj.new_record?
      label = "Create"
    end
    link_to "#{label} #{name}", edit_polymorphic_path(obj)
  end
end
