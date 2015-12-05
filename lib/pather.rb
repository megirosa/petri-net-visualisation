require 'securerandom'

module Pather
  extend self
  @paths = {}

  def path(page = :strona)
    @paths[page] or new_path(page)
  end

  def new_path(page = :strona)
    clear(page)
    @paths[page] = File.join('tmp',"output_#{SecureRandom.hex(30)}.png")
    @paths[page]
  end

  def clear(page = :strona)
    File.delete @paths[page] if @paths[page]
  rescue Errno::ENOENT
  end

  def clear_all
    @paths.keys.each {|page_id| clear(page_id)}
  end

  def dot_path(page = :strona)
    File.join('tmp', "output#{page}.dot")
  end

  def current_dot_path
    Pather.dot_path(MultiPage.current_page_name)
  end
end