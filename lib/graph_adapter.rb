require_relative 'graph_file_writer'

class GraphAdapter
  attr_accessor :nodes, :edges, :graph, :parsed_graph, :layout, :writer

  def initialize(layout = "dot")
    @layout = layout

    @nodes = {}
    @edges = {}

    @graph = GraphViz::new("page", "type" => "graph")
    @graph[:lwidth]  = 10
    @graph[:lheight] = 10
    @graph[:ratio]   = 1
    @graph[:rankdir] = "LR"

    @writer = GraphFileWriter.new
  end

  def translate_dsl(places, transitions)
    places.each { |place| add_place(place.name) }

    transitions.each do |transition|
      nodes[transition.name] = graph.add_nodes(transition.name)
      nodes[transition.name][:shape] = "rectangle"
      nodes[transition.name][:label] = transition.name

      transition.input_places.each { |input| add_edge(input.name, transition.name) }
      transition.output_places.each { |output| add_edge(transition.name, output.name) }
    end
  end

  def add_edge(start_name, end_name)
    graph.add_edges(nodes[start_name], nodes[end_name], dir: "forward", arrowhead: "normal")
  end

  def add_place(name)
    nodes[name] = graph.add_nodes(name)
    nodes[name][:shape] = "circle"
    nodes[name][:label] = name
  end

  def add_transition(name)
    nodes[name] = graph.add_nodes(name)
    nodes[name][:shape] = "rectangle"
    nodes[name][:label] = name
  end

  def draw
    graph.output(png: "tmp/output.png", use: layout)
  end

  def place_node(cursor_x, cursor_y, node_name)
    puts node_name
    writer.freeze_positions
    writer.update_position(cursor_x, cursor_y, graph_height, node_name)

    node = graph.get_node(node_name)

    if node
      node[:color] = "black"
      draw
    end
  end

  def select_node(cursor_x, cursor_y)
    node_name = find_node(cursor_x, cursor_y)
    if node_name
      node = graph.get_node(node_name)
      node[:color] = "coral"
      draw
    end
    node_name
  end

  def change_layout(layout)
    @layout = layout
    draw
  end

  private

  def find_node(cursor_x, cursor_y)
    parse_graph
    convert_positions
    nodes.each do |node_name, positions|
      node_x = positions[0]
      node_y = positions[1]
      distance = calculate_distance(node_x, node_y, cursor_x, cursor_y)

      return node_name if distance < 20 
    end 

    nil
  end

  def calculate_distance(node_x, node_y, cursor_x, cursor_y)
    Math.sqrt((node_x - cursor_x) ** 2 + (node_y - cursor_y) ** 2)
  end

  def graph_height
    parsed_graph['bb'].to_s.tr('"','').split(',').last.to_i
  end

  def convert_positions
    parsed_graph.each_node do |name, node|
      nodes[name] = node[:pos].to_s.tr('"','').split(',').map(&:to_i)
      nodes[name][1] = (graph_height - nodes[name][1]) * 1.37 + 4
      nodes[name][0] = nodes[name][0] * 1.37 + 4
    end
  end

  def parse_graph
    graph.output(dot: "tmp/output.dot", use: layout)
    GraphViz.parse("tmp/output.dot") { |g| @parsed_graph = g }
  end
end