require_relative 'graph_drawer'

module InterfaceElements
  attr_accessor :drawer

  def update
    @drawer = GraphDrawer.new
    @allow_move = false

    clear
    draw_menu
    draw_net
    draw_hover
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
    @net_image = image("tmp/output.png", margin: 10)
    @net_image.click do |image|
      edited = if moving_allowed?
        puts "node placed"
        drawer.place_node
      else
        puts "node selected"
        drawer.select_node
      end

      toggle_move if edited
    end
  end

  def draw_hover
    @hover_circle = oval(mouse[1], mouse[2], 50, 50, 
      fill: rgb(175, 238, 238, 0.5), 
      stroke: rgb(175, 238, 238),
      hidden: true)

    motion do |top, left| 
      @hover_circle.move(top - 25, left - 25)
    end
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

  private

  def toggle_move
    @allow_move = !@allow_move
    @hover_circle.hidden = !@hover_circle.hidden
  end

  def moving_allowed?
    @allow_move
  end
end