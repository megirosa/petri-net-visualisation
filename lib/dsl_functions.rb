def page(name)
  Page::created = Page.new(name)
  MultiPage.add_page(name, Page::created)
  MultiPage.current_page_name = name
  yield
  Page::created.prepare
  Page::clear_created
end

def subpage(name)
  raise "error" unless Page::created
  Page::created_subpage = Page.new(name)
  MultiPage.make_subpage_of_current_page(name)
  MultiPage.add_page(name, Page::created_subpage)
  MultiPage.current_page_name = name
  yield
  Page::created_subpage.prepare
  Page::clear_created_subpage
end

def place(name, methods = nil)
  new_place = Place.new(name, methods)
  Page::working_page.places << new_place
  new_place
end

def transition(name)
  Transition::created = Transition.new(name)
  yield
  Page::working_page.transitions << Transition::created
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