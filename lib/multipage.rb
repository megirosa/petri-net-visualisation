module MultiPage
  extend self
  @pages = {}
  @subpages = []

  attr_accessor :current_page_name

  def add_page(name, page)
    @pages[name] = page
  end

  def make_subpage_of_current_page(name)
    @subpages << name
  end

  def list
    @pages.keys.map do |name|
      if is_subpage?(name)
        "--#{id}"
      else
        "#{id}"
      end
    end
  end

  def pages
    @pages
  end

  def current_page
    @pages[current_page_name]
  end

  def switch_to_first
    @current_page_name = @pages.keys.first
  end

  def is_subpage?(name)
    @subpages.include?(name)
  end
end