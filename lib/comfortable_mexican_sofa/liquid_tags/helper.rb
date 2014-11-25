module ComfortableMexicanSofa::LiquidTags
  class Helper < Liquid::Tag
    Syntax = /(#{::Liquid::QuotedFragment}+)?/
    BLACKLIST = %w(eval class_eval instance_eval render)

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @helper_name = $1
      else
        raise ::Liquid::SyntaxError.new("Syntax Error in 'helper' - Valid syntax: helper <name>")
      end

      raise ::Liquid::SyntaxError.new("Helper '#{@helper_name}' is not allowed!") unless helper_allowed?

      super
    end

    def render(context)
      context.registers[:view].send @helper_name
    end

    def helper_allowed?
      whitelist = ::ComfortableMexicanSofa.config.allowed_helpers
      if whitelist.is_a?(Array)
        return true if whitelist.map!(&:to_s).member?(@helper_name)
      else
        return true unless BLACKLIST.member?(@helper_name)
      end
      false
    end
  end
end

Liquid::Template.register_tag('helper', ComfortableMexicanSofa::LiquidTags::Helper)
