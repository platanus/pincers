module Pincers::Core
  class Window

    attr_reader :handler

    def initialize(_context, _handler)
      @context = _context
      @handler = _handler
    end

    def title
      visit { @context.title }
    end

    def url
      visit { @context.url }
    end

    def uri
      visit { @context.uri }
    end

    def goto
      wrap_errors { backend.switch_to_window handler }
    end

    def visit
      current_window = @context.window
      is_current = (current_window.handler == handler)

      begin
        goto unless is_current
        return yield
      ensure
        current_window.goto unless is_current
      end
    end

    def close
      visit do
        wrap_errors { backend.close_current_window }
      end
    end

  private

    def backend
      @context.backend
    end

    def wrap_errors
      begin
        yield
      rescue Pincers::Error
        raise
      rescue Exception => exc
        raise Pincers::BackendError.new(@context, exc)
      end
    end

  end
end