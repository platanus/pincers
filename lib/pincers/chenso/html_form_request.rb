module Pincers::Chenso
  class HtmlFormRequest < HtmlPageRequest
    def initialize(_form)
      super _form.action, _form.method, _form.inputs, _form.encoding
    end
  end
end