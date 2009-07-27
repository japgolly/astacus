module RailsReflection

  def all_models
    @@all_models||= (
      Dir.glob('app/models/**/*.rb').each{|f| require f}
      Object.constants.map{|c| eval c}.select{|c| c.respond_to? :table_name}
    )
  end
end