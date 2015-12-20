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

  def fire_transitions
    adapter.parse_graph
    
    transition_to_fire = transitions.select { |transition| transition.fireable? }.sample
    return false unless transition_to_fire
    transition_to_fire.input_places.each { |input| move_token(:take, input) }
    transition_to_fire.output_places.each { |output| move_token(:add, output) }
    adapter.writer.parse
    
    true
  end

  def move_token(action, place)
    place.send("#{action}_token")
    adapter.update_label(place.name, place.tokens)
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

  def export
    exported_places = places.map(&:export).join
    exported_transitions = transitions.map(&:export).join
    
    "page :#{@name} do\n#{exported_places}\n#{exported_transitions}end"
  end
end