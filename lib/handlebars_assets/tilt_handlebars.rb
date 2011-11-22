require 'tilt'

module HandlebarsAssets
  class TiltHandlebars < Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    def evaluate(scope, locals, &block)
      name = basename(scope.logical_path)
      compiled_hbs = Handlebars.precompile(data)

      if name.starts_with?('_')
        partial_name = scope.logical_path.sub(/#{name}$/, name[1..-1]).to_s
        <<-PARTIAL
          (function() {
            Handlebars.registerPartial('#{partial_name}', Handlebars.template(#{compiled_hbs}));
          }).call(this);
        PARTIAL
      else
        template_name = scope.logical_path.to_s
        <<-TEMPLATE
          function(context) {
            return HandlebarsTemplates['#{template_name}'](context);
          };
          this.HandlebarsTemplates || (this.HandlebarsTemplates = {});
          this.HandlebarsTemplates['#{template_name}'] = Handlebars.template(#{compiled_hbs});
        TEMPLATE
      end
    end

    protected
    
    def basename(path)
      path.sub(%r{.*/}, '')
    end

    def prepare; end
  end
end
