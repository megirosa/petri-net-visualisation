def page(name)
  Page::created = Page.new
  yield
  Page::created.translate_dsl
  Page::created.draw
end

def place(name, methods = nil)
  new_place = Place.new(name, methods)
  Page::created.places << new_place
  new_place
end

def transition(name)
  Transition::created = Transition.new(name)
  yield
  Page::created.transitions << Transition::created
  Transition::created = nil
end

def input(place)
  raise "error" unless Transition::created
  Transition::created.input_places << place
end

def output(place, &anchor)
  raise "error" unless Transition::created
  Transition::created.output_places << place
  Transition::created.output_anchors << anchor
end