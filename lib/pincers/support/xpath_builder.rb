module Pincers::Support
  class XPathBuilder

    def initialize(_options={})
      @parts = []
      by_tag _options.delete(:tag) if _options.key? :tag
      by_content _options.delete(:content) if _options.key? :content

      if _options.key? :class
        _options.delete(:class).split(' ').each { |c| by_class c }
      end

      _options.each do |key, value|
        by_attribute key, contains: value
      end
    end

    def expression
      ".//*[#{@parts.join(' and ')}]"
    end

    def by_tag(_name)
      add "name()='#{_name.downcase}'"
      self
    end

    def by_content(_contents, _options={})
      # TODO: more options, lowercase support?
      # xpath("//*[text()='#{_contents}'] | //*[@value='#{_contents}']", _options)
      add "(contains(text(), '#{_contents}') or contains(@value, '#{_contents}'))"
    end

    def by_class(_class, _options={})
      add "contains(concat(' ', @class, ' '), ' #{_class} ')"
    end

    def by_attribute(_attribute, _options={})
      add(if _options.key? :equals
        "@#{_attribute}='#{_options.delete(:equals)}'"
      elsif _options.key? :starts_with
        "starts-with(@#{_attribute}, '#{_options.delete(:starts_with)}')"
      elsif _options.key? :ends_with
        ends_with = _options.delete(:ends_with)
        "substring(@#{_attribute}, string-length(@#{_attribute}) - string-length('#{ends_with}') + 1)='#{ends_with}'"
      elsif _options.key? :contains
        "contains(@#{_attribute}, '#{_options.delete(:contains)}')"
      else
        "#{_attribute}"
      end)
    end

  private

    def add(_condition)
      @parts << _condition
      self
    end

  end
end