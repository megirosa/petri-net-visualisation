class GraphAdapter
  attr_accessor :nodes, :edges, :graph

  def initialize
    @nodes = {}
    @edges = {}

    @graph = GraphViz::new("page", "type" => "graph")
    @graph[:lwidth]  = 10
    @graph[:lheight] = 10
    @graph[:ratio]   = 1
    @graph[:rankdir] = "LR"
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
    graph.output(png: "tmp/output.png")
  end
end