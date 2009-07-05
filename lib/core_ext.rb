class Object
  def safe_to_i
    self
  end
end

class String
  def safe_to_i
    self =~ /^\d+$/ ? to_i : self
  end
end