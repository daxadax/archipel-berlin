module Services
  class PdfGenerator
    include Prawn::View

    def initialize(path, title, subtitles = [])
      @path = path
      @title = title
      @subtitles = subtitles
    end

    def call(&block)
      set_fonts
      write_header

      document.move_cursor_to 700

      yield(document)

      save_as(path)
    end

    private
    attr_reader :path, :title, :subtitles

    def document
      @document ||= Prawn::Document.new(page_size: 'A4')
    end

    def set_fonts
      document.font_families.update("Arial" => {
        :normal => "./fonts/arial.ttf",
        :bold => "./fonts/arial-bold.ttf"
      })

      document.font 'Arial'
    end

    def write_header
      document.text title, style: :bold, align: :left, size: 18
      image image_path('archipel-logo.jpg'), at: [415, 780], width: 100
      subtitles.each do |subtitle|
        document.text subtitle, style: :bold, align: :left
      end
    end

    def image_path(filename)
      File.expand_path("../../public/images/#{filename}", File.dirname(__FILE__))
    end
  end
end
