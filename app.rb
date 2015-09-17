require 'shoes'
require 'ruby-graphviz'

require_relative 'modules/graph_elements_interface'

load ARGV[1]

Shoes.app(width: 800, title: "Petri Net") do
  extend GraphElementsInterface

  update
end