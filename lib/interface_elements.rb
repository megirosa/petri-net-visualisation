require_relative 'graph_drawer'

module InterfaceElements
  attr_accessor :drawer

  def update
    @drawer = GraphDrawer.new

    clear
    draw_menu
    draw_net
  end

  def draw_menu
    flow(height: 200) do
      stack(width: 250, margin: 10) do
        caption "Add new place"
        para "Name:"
        place_name = edit_line
        draw_button("Add place") { add_place_action(place_name.text) }
      end

      stack(width: 250, margin: 10) do
        caption "Add new transition"
        para "Start place:"
        start_name = list_box(items: drawer.places_to_select)
        para "End place:"
        end_name = list_box(items: drawer.places_to_select)
        para "Name:"
        trans_name = edit_line
        draw_button("Add transition") { add_transition_action(start_name.text, end_name.text, trans_name.text) }
      end

      stack(width: 250, margin: 10) do
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
    image("tmp/output.png", margin: 10)
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
    window(width: 250, height: 250, title: "Export to file") do
      stack(margin: 10) do
        para "Enter file name:"
        file_name = edit_line
        button "Export" do
          begin
            File.open("export/#{file_name.text}.rb", 'w') do |file| 
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