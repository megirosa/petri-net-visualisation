require 'green_shoes'
require 'ruby-graphviz'

require_relative 'modules/graph_elements_interface'

load ARGV[0]

Shoes.app(width: 800, title: "Petri Net") do
  extend GraphElementsInterface

  def update

    @app.append do
      draw_menu
      draw_net
    end
  end

  update
end