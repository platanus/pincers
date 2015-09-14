require "pincers/chenso/browsing_context"

module Pincers::Chenso
  class BrowsingManager
    extend Forwardable

    def_delegators :context, :document, :current_url, :push, :forward, :back, :refresh

    def initialize(_client)
      @client = _client
      @index = 0
      @windows = [
        [load_new_context]
      ]
    end

    def switch_window(_index)
      @index = _index
      switch_top_frame
    end

    def switch_frame(_id)
      new_context = context.get_child _id
      return false if new_context.nil?
      window << new_context
      return true
    end

    def switch_top_frame
      window.slice!(1..-1) if window.length > 1
    end

    def switch_parent_frame
      window.pop if window.length > 1
    end

    def load_frame(_id, _request)
      window << context.load_child(_id, _request)
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

    def context
      window.last
    end

    def load_new_context(_request=nil)
      ctx = BrowsingContext.new @client
      ctx.push _request if _request
      ctx
    end

  end
end