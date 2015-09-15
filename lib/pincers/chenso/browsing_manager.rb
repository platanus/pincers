require "pincers/chenso/browsing_context"

module Pincers::Chenso
  class BrowsingManager
    extend Forwardable

    def_delegators :context, :document, :current_url, :push, :forward, :back, :refresh

    def initialize(_client)
      @client = _client
      @index = 0
      @windows = [
        [build_root_context]
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
      child_context = context.load_child _id
      child_context.push _request
      window << child_context
    end

    def load_window(_request)
      context = build_root_context
      context.push _request
      windows << [context]
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

    def build_root_context
      BrowsingContext.new @client
    end

  end
end