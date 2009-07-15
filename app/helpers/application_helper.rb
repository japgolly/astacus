# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def model_errors_to_single_string(model)
    model.errors.map{|a| "#{a[0].capitalize} #{a[1]}."}.join("\n\n")
  end
end
