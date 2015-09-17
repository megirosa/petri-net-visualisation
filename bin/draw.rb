require 'shoes'
require 'ruby-graphviz'

require_relative '../lib/interface_elements'

file = ARGV[1]

unless file
  puts "No file given."
  return
end

load file

Shoes.app(width: 800, title: "Petri Net") do
  extend InterfaceElements

  update
end