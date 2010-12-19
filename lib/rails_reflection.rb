module RailsReflection

  def all_models
    @@all_models||= (
      Dir.glob('app/models/**/*.rb').each{|f|
        model_name= f.gsub(/^.+[\\\/]|\.rb$/,'').camelize
        model_name.constantize rescue require f
      }
      Object.constants.reject{|c| c =~ /^RAILS_/}.map{|c| eval c}.select{|c| c.respond_to? :table_name}
    )
  end
end
