module DeviseHelper
    # A simple way to show error messages for the current devise resource. If you need
    # to customize this method, you can either overwrite it in your application helpers or
    # copy the views to your application.
    #
    # This method is intended to stay simple and it is unlikely that we are going to change
    # it to add more behavior or options.

    # ======= devise_error_messages =======
    def devise_error_messages!
        puts "\n******* devise_error_messages *******"

        # == The resource object is the model being used by devise
        return "" if resource.errors.empty?

        messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
        puts "messages: #{messages.inspect}"
        sentence = I18n.t("errors.messages.not_saved",
                  count: resource.errors.count,
                  resource: resource.class.model_name.human.downcase)
        puts "sentence: #{sentence.inspect}"

        html = <<-HTML
        <div id="error_explanation">
            <h2>#{sentence}</h2>
            <ul>#{messages}</ul>
        </div>
        HTML

        html.html_safe
    end
end
