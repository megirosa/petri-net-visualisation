require_relative 'graph_adapter'

class Page
  attr_accessor :places, :transitions, :adapter

  @@created = nil

  def self.created
    @@created
  end
  
  def self.created=(value)
    @@created = value
  end

  def initialize
    @places = []
    @transitions = []
    @adapter = GraphAdapter.new
  end

  def translate_dsl
    adapter.translate_dsl(places, transitions)
  end

  def add_edge(start_name, end_name)
    adapter.add_edge(start_name, end_name)
  end

  def add_place(name)
    adapter.add_place(name)
  end

  def add_transition(name)
    return if transitions.any? { |transition| transition.name == name }
    transitions << Transition.new(name)
    adapter.add_transition(name)
  end

  def draw
    adapter.draw
  end

  def find_transition(name)
    transitions.detect{ |t| t.name == name }
  end

  def find_place(name)
    places.detect{ |p| p.name == name }
  end

  def export(name)
    exported_places = places.map(&:export).join
    exported_transitions = transitions.map(&:export).join
    
    "page :#{name} do\n#{exported_places}\n#{exported_transitions}end"
  end
end