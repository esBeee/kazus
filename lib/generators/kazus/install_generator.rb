module Kazus
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializer
        template "kazus.rb", "config/initializers/kazus.rb"
      end
    end
  end
end
