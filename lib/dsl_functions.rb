def page(name)
  if Page::created.nil?
    Page::created = Page.new(name)
    MultiPage.add_page(name, Page::created)
    MultiPage.current_page_name = name
    yield
    Page::created.prepare
    Page::created = nil
  else
    Page::created_subpage = Page.new(name)
    MultiPage.make_subpage_of_current_page(name)
    MultiPage.add_page(name, Page::created_subpage)
    MultiPage.current_page_name = name
    yield
    Page::created_subpage.prepare
    Page::created_subpage = nil  
  end
end

def sub_page(file_name)
  raise MalformedDslError, "'sub_page' statement outside of 'page' statement" unless Page::created
  load file_name
end

def place(name, methods = {})
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
  raise MalformedDslError, "'input' statement outside of 'page' statement" unless Transition::created
  Transition::created.input_places << place
end

def output(place, &anchor)
  raise MalformedDslError, "'output' statement outside of 'page' statement" unless Transition::created
  Transition::created.output_places << place
  Transition::created.output_anchors << anchor
end

class MalformedDslError < StandardError; end