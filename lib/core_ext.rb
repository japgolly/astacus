class Object
  def safe_to_i
    self
  end
  alias_method :safe_to_f, :safe_to_i
end

class String
  def safe_to_i
    self =~ /^\-?\d+$/ ? to_i : self
  end

  def safe_to_f
    self =~ /^\-?\d+(?:\.\d+)?$/ ? to_f : self
  end
end