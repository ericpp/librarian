module Librarian
  module Source
    class Git
      class Repository

        class << self
          def clone!(root_module, path, repository_url)
            path = Pathname.new(path)
            path.mkpath
            git = new(root_module, path)
            git.clone!(repository_url)
            git
          end
        end

        attr_reader :root_module, :path

        def initialize(root_module, path)
          path = Pathname.new(path)
          @root_module = root_module
          @path = path
        end

        def git?
          path.join('.git').exist?
        end

        def clone!(repository_url)
          within do
            command = "clone #{repository_url} ."
            run!(command)
          end
        end

        def checkout!(reference)
          within do
            command = "checkout #{reference}"
            run!(command)
          end
        end

      private

        def run!(text)
          text = "git #{text}"
          debug { "Running `#{text}` in #{relative_path_to(Dir.pwd)}" }
          `#{text}`
        end

        def relative_path_to(path)
          root_module.project_relative_path_to(path)
        end

        def debug
          root_module.ui.debug "[Librarian] #{yield}"
        end

        def within
          Dir.chdir(path) { yield }
        end

      end
    end
  end
end
