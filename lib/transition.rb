class Transition
  attr_accessor :name, :input_places, :output_places, :output_anchors
  
  @@created = nil

  def self.created
    @@created
  end
  
  def self.created=(value)
    @@created = value
  end

  def initialize(name)
    @name = name
    @input_places = []
    @output_places = []
    @output_anchors = []
  end

  def export
    outputs = output_places.map{ |o| "\t\toutput #{o.name}" }.join("\n")
    inputs = input_places.map{ |i| "\t\tinput #{i.name}" }.join("\n")
    
    "\ttransition \"#{name}\" do\n#{inputs}\n\n#{outputs}\n\tend\n"
  end
end