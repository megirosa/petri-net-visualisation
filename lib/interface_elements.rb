module InterfaceElements
  attr_accessor :drawer
  @@net_image = nil

  def update
    @drawer = GraphDrawer.new
    net_image.remove if net_image

    clear
    draw_menu
    draw_net
    draw_hover
  end

  def draw_menu
    @hidden_hover = true

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
        stack do
          caption "Save DSL file"
          draw_button("Export") { export_action }
        end

        stack(margin_top: 10) do
          caption "Layout algorithm"
          layout_algorithm_name = list_box(items: layout_algorithms_list)
          draw_button("Change") { change_layout_action(layout_algorithm_name.text) }
        end
      end

      stack(width: 250, margin: 10) do
        stack do
          caption "Current page"
          current_page_name = list_box(items: MultiPage.list)
          draw_button("Switch to") { change_page_action(current_page_name.text) }
        end

        flow(margin_top: 10) do
          caption "Fire transitions"
          stack do
            draw_button("Single") { fire_transitions_action }
          end

          stack do
            @fire_continouously_button = draw_button("Continouously") { fire_continouously_action }
          end
        end
      end
    end
  end

  def fire_transitions_action()
    MultiPage.current_page.fire_transitions
    update
  end

  def fire_continouously_action()
    @timer = animate(1) do |i|
      fired = MultiPage.current_page.fire_transitions
      @timer.stop unless fired

      update
    end
  end

  def change_page_action(page_id)
    MultiPage.current_page_name = page_id.tr('- ','').to_sym
    update
  end

  def draw_net
    self.net_image = image(Pather.path(MultiPage.current_page_name), margin: 10)
    net_image.click do |image|
      if selected?
        place_node
      else
        select_node
      end

      if placed? || selected?
        net_image.remove
        draw_net
        toggle_move
        draw_hover
      end
    end
  end

  def draw_hover
    @hover_circle = oval(mouse[1] - 25, mouse[2] - 25, 50, 50, 
      fill: rgb(175, 238, 238, 0.5), 
      stroke: rgb(175, 238, 238),
      hidden: @hidden_hover)

    motion do |top, left| 
      @hover_circle.move(top - 25, left - 25)
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

  def change_layout_action(layout)
    drawer.change_layout(layout)
    update
  end

  def export_action
    window(width: 250, height: 250, title: "Export to file") do
      stack(margin: 10) do
        para "Enter file name:"
        file_name = edit_line
        button "Export" do
          begin
            File.open("export/#{file_name.text}.rb", 'w') do |file| 
              file.write(MultiPage.current_page.export)
            end
            close
          rescue
            puts $!, $@
          end
        end
      end
    end
  end

  def net_image
    @@net_image
  end

  def net_image=(new_net_image)
    @@net_image = new_net_image
  end

  def self.net_image
    @@net_image
  end

  private

  def toggle_move
    @hidden_hover = !@hidden_hover
  end

  def selected?
    !!@selected_node
  end

  def placed?
    !!@placed_node
  end

  def cursor_x
    mouse[1] - net_image.left
  end

  def cursor_y
    mouse[2] - net_image.top
  end

  def layout_algorithms_list
    %w(dot neato twopi circo fdp)
  end

  def select_node
    @selected_node = drawer.select_node(cursor_x, cursor_y)
    @placed_node = nil
  end

  def place_node
    @placed_node = drawer.place_node(cursor_x, cursor_y, @selected_node)
    if placed?
      @selected_node = nil
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
end