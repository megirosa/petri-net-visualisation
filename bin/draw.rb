require 'shoes'
require 'ruby-graphviz'

require_relative '../lib/calculations.rb'
require_relative '../lib/dsl_functions.rb'
require_relative '../lib/graph_adapter.rb'
require_relative '../lib/graph_drawer.rb'
require_relative '../lib/graph_file_writer.rb'
require_relative '../lib/interface_elements.rb'
require_relative '../lib/multipage.rb'
require_relative '../lib/page.rb'
require_relative '../lib/pather.rb'
require_relative '../lib/place.rb'
require_relative '../lib/transition.rb'

file = ARGV[1]

unless file
  puts "No file given."
  return
end

Pather.clear_all

begin
  load file
rescue MalformedDslError
  puts "Could not parse DSL:\n  #{$!}"
end

begin
  Shoes.app(width: 1000, title: "Petri Net") do
    extend InterfaceElements
    
    MultiPage.switch_to_first
    update
  end
ensure
  Pather.clear_all
end