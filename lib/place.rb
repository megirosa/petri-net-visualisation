class Place
  attr_accessor :name, :methods, :tokens

  def initialize(name, methods = {})
    @name, @methods = name, methods
    @tokens = methods.size
  end

  def has_tokens?
    tokens > 0
  end

  def take_token
    @tokens -= 1
  end

  def add_token
    @tokens += 1
  end

  def export
    "\t#{name} = place \"#{name}\", #{methods.to_s}\n"
  end
end