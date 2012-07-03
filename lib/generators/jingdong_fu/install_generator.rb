module JingdongFu
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy JingdongFu default files"
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine

      def copy_config
        directory 'config'
      end
    end
  end
end
