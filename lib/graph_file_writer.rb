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
    @graph_file = IO.read(Pather.current_dot_path)
  end

  def write(lines)
    IO.write(Pather.current_dot_path, lines)
  end

  def parse
    parsed_graph = GraphViz.parse(Pather.current_dot_path)
    `neato -q2 -Tpng -n -o#{Pather.new_path(MultiPage.current_page_name)} #{Pather.current_dot_path}`  
  end

  def position_line?(line)
    (line =~ /pos=/) && !(line =~ /(\-\>)|(\]\;$)/)
  end

  def searched_name_line?(line, node_name)
    line.include?("label=#{node_name}")
  end

  def freeze!(line)
    line.gsub!(/\d"/){ |match| "#{match[0]}!\"" }
  end
end