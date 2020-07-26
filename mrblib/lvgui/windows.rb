# Helpers for window types

module LVGUI
  # Helper methods to help creating a "button palette" kind of window.
  module ButtonPalette
    def add_button(label)
      Button.new(@container).tap do |btn|
        add_to_focus_group(btn)
        btn.glue_obj(true)
        btn.set_label(label)
        btn.event_handler = ->(event) do
          case event
          when LVGL::EVENT::CLICKED
            yield
          end
        end
      end
    end

    def add_buttons(list)
      list.each do |pair|
        label, action = pair
        add_button(label, &action)
      end
    end
  end

  module Window
    # Include with +include LVGUI::Window::WithBackButton+ and
    # use e.g. +goes_back_to ->() { MainWindow.instance }+
    module WithBackButton
      def self.included(base)
        base.extend ClassMethods
      end

      # Class methods included by WithBackButton
      module ClassMethods
        # A lambda (or proc)'s return value will determine which instance
        # of an object the button will link to.
        #
        # This is done through a proc/lambda because otherwise it ends up
        # depending on the singleton instance of windows directly.
        def goes_back_to(prc)
          class_variable_get(:@@_after_initialize_callback) << proc do
            btn = LVGUI::BackButton.new(@toolbar, prc.call())
            add_to_focus_group(btn)
            @container.refresh
          end
        end
      end
    end
  end
end
