module Pincers::Extension
  module Labs

    def readonly(&_block)
      nk_root = Pincers.for_nokogiri to_html

      unless root?
        nk_root = nk_root.css('body > *') # nokogiri will inject valid html structure around contents
      end

      if _block.nil?
        nk_root
      else
        _block.call(nk_root)
      end
    end

  end
end