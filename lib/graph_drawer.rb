require_relative 'page'
require_relative 'place'
require_relative 'transition'
require_relative 'dsl_functions'

class GraphDrawer
  attr_accessor :current_page, :adapter

  def initialize
    @current_page = Page::created
    @adapter = @current_page.adapter
  end

  def places_to_select
    current_page.places.map(&:name) + [""]
  end

  def add_place(name)
    raise DrawingError, "Empty place name." if name.empty?
    raise DrawingError, "Place with given name already exists." if current_page.find_place(name)

    current_page.places << Place.new(name, {})
    current_page.add_place(name)
    current_page.draw
  end

  def add_transition(start_name, end_name, transition_name)
    raise DrawingError, "Empty transition name." if transition_name.empty?
    raise DrawingError, "No place selected." if end_name.nil? && start_name.nil?

    current_page.add_transition(transition_name)
    
    unless start_name.nil?
      current_page.add_edge(start_name, transition_name) 
      current_page.find_transition(transition_name).input_places << current_page.find_place(start_name)
    end

    unless end_name.nil?
      current_page.add_edge(transition_name, end_name)
      current_page.find_transition(transition_name).output_places << current_page.find_place(end_name)
    end

    current_page.draw
  end

  def place_node(cursor_x, cursor_y, node_name)
    adapter.place_node(cursor_x, cursor_y, node_name)
    #TODO remove when placing works
    true
  end

  def select_node(cursor_x, cursor_y)
    adapter.select_node(cursor_x, cursor_y)
  end

  def change_layout(layout)
    adapter.change_layout(layout)
  end

  class DrawingError < StandardError; end
end