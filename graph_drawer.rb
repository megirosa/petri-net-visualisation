require_relative 'page'
require_relative 'place'
require_relative 'transition'
require_relative 'dsl_functions'

class GraphDrawer
  attr_accessor :current_page

  def initialize
    @current_page = Page::created
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
    
    unless start_name.empty?
      current_page.add_edge(start_name, transition_name) 
      current_page.find_transition(transition_name).input_places << current_page.find_place(start_name)
    end

    unless end_name.empty?
      current_page.add_edge(transition_name, end_name)
      current_page.find_transition(transition_name).output_places << current_page.find_place(end_name)
    end

    current_page.draw
  end

  class DrawingError < StandardError; end
end