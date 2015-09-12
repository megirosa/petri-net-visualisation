require_relative '../graph_drawer'

module GraphElementsInterface
  attr_accessor :drawer

  def update
    @drawer = GraphDrawer.new

    clear
    draw_menu
    draw_net
  end

  def draw_menu
    flow(height: 100) do
      flow do
        place_name = edit_line
        draw_button("Add place") { add_place_action(place_name.text) }
      end

      flow do
        start_name = list_box(items: drawer.places_to_select)
        end_name = list_box(items: drawer.places_to_select)
        trans_name = edit_line
        draw_button("Add transition") { add_transition_action(start_name.text, end_name.text, trans_name.text) }
      end

      flow do
        draw_button("Export") { export_action }
      end
    end
  end

  def add_place_action(name)
    drawer.add_place(name)
    update
  rescue GraphDrawer::DrawingError => e
    puts "Could not add place. #{e.message}"
  end

  def add_transition_action(start_name, end_name, trans_name)
    drawer.add_transition(start_name, end_name, trans_name)
    update
  rescue GraphDrawer::DrawingError => e
    puts "Could not add transition. #{e.message}"
  end

  def draw_net
    @net_image = image "tmp/output.png"
  end

  def draw_button(label)
    button(label) do
      begin
        yield
      rescue
        puts $!, $@
      end
    end
  end

  def export_action
    window(width: 200, height: 200) do
      stack do
        para "Enter file name:"
        file_name = edit_line
        @ok_field = button "Export" do
          begin
            File.open("export/#{@file_name.text}.rb", 'w') do |file| 
              file.write(Page::created.export(file_name.text))
            end
            close
          rescue
            puts $!, $@
          end
        end
      end
    end
  end
end