require 'green_shoes'
require 'ruby-graphviz'

require_relative 'page'
require_relative 'place'
require_relative 'transition'
require_relative 'dsl_functions'

load ARGV[0]

Shoes.app(width: 800, title: "Petri Net") do
  def update
    @app.clear
    @app.append do
      net = image "output.png"

      flow do
        @place_name_field = edit_line
        @add_place_field = draw_button("Add place") do
          add_place_action
        end
      end

      flow do
        @start_node_field = list_box(items: Page::created.places.map(&:name) + [""])
        @end_node_field = list_box(items: Page::created.places.map(&:name) + [""])
        @trans_name_field = edit_line
        add_transition = draw_button("Add transition") do
          add_transition_action
        end
      end

      flow do
        @export_field = draw_button("Export") do
          export_action
        end
      end
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

  def add_place_action
    name = @place_name_field.text
    if !name.empty? && !Page::created.find_place(name)
      Page::created.places << Place.new(name, {})
      Page::created.add_place(name)
      Page::created.draw
      update
    end
  end

  def add_transition_action
    start_name = @start_node_field.text
    end_name = @end_node_field.text
    transition_name = @trans_name_field.text
    if !transition_name.empty? && !(end_name.empty? && start_name.empty?)
      Page::created.add_transition(transition_name)
      unless start_name.empty?
        Page::created.add_edge(start_name, transition_name) 
        Page::created.find_transition(transition_name).input_places << 
          Page::created.find_place(start_name)
      end
      unless end_name.empty?
        Page::created.add_edge(transition_name, end_name)
        Page::created.find_transition(transition_name).output_places << 
          Page::created.find_place(end_name)
      end
      Page::created.draw
      
      update
    end
  end

  def export_action
    window(width:200, height:200) do
      stack do
        para "Enter file name:"
        @file_name_field = edit_line
        @ok_field = button "Export" do
          begin
            File.open("#{@file_name_field.text}.rb", 'w') do |file| 
              file.write(Page::created.export(@file_name_field.text))
            end
            close
          rescue
            puts $!, $@
          end
        end
      end
    end
  end

  update
end