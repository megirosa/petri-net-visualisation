class Place
  attr_accessor :name, :methods

  def initialize(name, methods)
    @name, @methods = name, methods
  end

  def export
    "\t#{name} = place \"#{name}\"\n"
  end
end