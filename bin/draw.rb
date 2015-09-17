require 'shoes'
require 'ruby-graphviz'

require_relative '../lib/interface_elements'

load ARGV[1]

Shoes.app(width: 800, title: "Petri Net") do
  extend InterfaceElements

  update
end