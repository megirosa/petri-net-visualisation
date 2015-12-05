class Page
  attr_accessor :places, :transitions, :adapter, :name
  @@created = nil
  @@created_subpage = nil

  def self.created
    @@created
  end
  
  def self.created=(value)
    @@created = value
  end

  def self.created_subpage
    @@created_subpage
  end
  
  def self.created_subpage=(value)
    @@created_subpage = value
  end

  def self.clear_created
    @@created = nil
  end

  def self.clear_created_subpage
    @@created_subpage = nil
  end

  def self.working_page
    @@created_subpage || @@created
  end

  def initialize(name)
    @name = name
    @places = []
    @transitions = []
    @adapter = GraphAdapter.new(name)
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

  def prepare
    translate_dsl
    draw
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