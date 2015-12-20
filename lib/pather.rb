require 'securerandom'

module Pather
  extend self
  @paths = {}

  def path(page)
    @paths[page] or new_path(page)
  end

  def new_path(page)
    clear(@paths[page]) if @paths[page]
    @paths[page] = File.join('tmp',"output_#{SecureRandom.hex(30)}.png")
    @paths[page]
  end

  def clear(file_name)
    File.delete file_name
  rescue Errno::ENOENT
    puts "Could not delete file"
  end

  def clear_all
    @paths.keys.each do |page_name| 
      clear(@paths[page_name])
      clear(dot_path(page_name))
    end
  end

  def dot_path(page)
    File.join('tmp', "output_#{page}.dot")
  end

  def current_dot_path
    Pather.dot_path(MultiPage.current_page_name)
  end
end