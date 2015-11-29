require_relative 'calculations'

class GraphFileWriter
  include Calculations
  attr_accessor :graph_file

  def freeze_positions
    read
    graph_edited_lines = graph_file.lines.map do |line|
      if position_line?(line)
        freeze!(line)
      end
      line
    end.join
    write(graph_edited_lines)
  end

  def update_position(x, y, graph_height, node_name)
    read
    update_next_position = false

    graph_edited_lines = graph_file.lines.map do |line|
      if searched_name_line?(line, node_name)
        update_next_position = true
      elsif position_line?(line) && update_next_position
        line.sub!(/\d+(\.\d+)?/){ |match| ((to_points(x) - 4)).round(3).to_s }
        line.sub!(/,\d+(\.\d+)?/){ |match| ','+((to_points((graph_height-y)) - 4)).round(3).to_s }

        freeze!(line)
        update_next_position = false
      end
      line
    end.join

    write(graph_edited_lines)
    parse
  end

  private

  def read
    @graph_file = IO.read("tmp/output.dot")
  end

  def write(lines)
    IO.write("tmp/output.dot", lines)
  end

  def parse
    parsed_graph = GraphViz.parse("tmp/output.dot")
    #parsed_graph.output(png: "tmp/output.png", use: "neato")
    `neato -q2 -Tpng -n -o tmp/output.png tmp/output.png`
  end

  def position_line?(line)
    (line =~ /pos=/) && !(line =~ /(\-\>)|(\]\;$)/)
  end

  def searched_name_line?(line, node_name)
    line.include?("label=#{node_name}")
  end

  def inch?(line)
    line =~ /\./ 
  end

  def to_inches!(line)
    line.gsub!(/\d+/){ |match| (1/72.0*match.to_i/1.37).round(3).to_s }
  end

  def freeze!(line)
    line.gsub!(/\d"/){ |match| "#{match[0]}!\"" }
  end
end