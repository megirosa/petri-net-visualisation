class GraphFileWriter
  attr_accessor :graph_file

  def freeze_positions
    read
    graph_edited_lines = graph_file.lines.map do |line|
      if position_line?(line)
        to_inches!(line) unless inch?(line)
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
        line.sub!(/\d+(.\d+)?/){ |match| ((x-4) /72.0/1.37).round(3).to_s }
        line.sub!(/,\d+(.\d+)?/){ |match| ','+((graph_height-y-4) /72.0/1.37).round(3).to_s }

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
    parsed_graph.output(png: "tmp/output.png", use: "neato")
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