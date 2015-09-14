require "pincers/support/http_navigator"

module Pincers::Chenso
  class ContextManager

    class Context < Struct.new(:navigator, :document, :child_cache); end

    def initialize(_client)
      @client = _client
      @index = 0
      @windows = [
        [load_new_context]
      ]
    end

    def context
      window.last
    end

    def push(_request)
      update_context context.navigator.push _request
    end

    def forward(_steps)
      update_context context.navigator.forward _steps
    end

    def back(_steps)
      update_context context.navigator.back _steps
    end

    def refresh
      update_context context.navigator.refresh
    end

    def switch_window(_index)
      @index = _index
      switch_top_frame
    end

    def switch_frame(_id)
      new_context = context.child_cache[_id]
      return false if new_context.nil?
      window << new_context
      return true
    end

    def switch_top_frame
      window.slice!(1..-1) if window.length > 1
      puts window.length
    end

    def switch_parent_frame
      window.pop if window.length > 1
    end

    def load_frame(_id, _request)
      new_context = load_new_context(_request)
      context.child_cache[_id] = new_context
      window << new_context
    end

    def load_window(_request)
      windows << [load_new_context(_request)]
      @index = windows.length - 1
    end

  private

    attr_reader :windows

    def window
      @windows[@index]
    end

    def load_new_context(_request=nil)
      nav = build_navigator
      doc = nav.push _request if _request
      Context.new nav, doc, {}
    end

    def update_context(_document)
      context.document = _document
      clear_frame_cache
    end

    def build_navigator
      Pincers::Support::HttpNavigator.new @client
    end

    def clear_frame_cache
      context.child_cache.clear
    end

  end
end