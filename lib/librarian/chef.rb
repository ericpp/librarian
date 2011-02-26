require 'librarian/specfile'
require 'librarian/source'
require 'librarian/chef/cookbook'
require 'librarian/chef/source'

module Librarian
  module Chef
    extend self
    include Librarian
    extend Librarian

    class Dsl < Specfile::Dsl
      dependency :cookbook => Cookbook

      source :site => Source::Site
      source :git => Source::Git
      source :path => Source::Path
    end

    module Overrides
      def specfile_name
        'Cheffile'
      end

      def install_path
        project_path.join('cookbooks')
      end

      def dsl_class
        Dsl
      end
    end

    include Overrides
    extend Overrides

  end
end
