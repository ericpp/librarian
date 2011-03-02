require 'tsort'

require 'librarian/helpers/debug'

require 'librarian/dependency'

module Librarian
  class Resolver

    class GraphHash < Hash
      include TSort
      alias tsort_each_node each_key
      def tsort_each_child(node, &block)
        self[node].each(&block)
      end
    end

    include Helpers::Debug

    attr_reader :root_module

    def initialize(root_module)
      @root_module = root_module
    end

    def resolve(source, dependencies)
      manifests = {}
      queue = dependencies.dup
      until queue.empty?
        dependency = queue.shift
        unless manifests.key?(dependency.name)
          debug { "Resolving #{dependency.name}" }
          manifest = dependency.manifests.first
          subdeps = manifest.
            dependencies.
            reject{|d| manifests.key?(d.name)}.
            map{|d| Dependency.new(d.name, d.requirement.as_list, source)}
          queue.concat(subdeps)
          manifests[dependency.name] = manifest
        end
      end
      manifest_pairs = GraphHash[manifests.map{|k, m| [k, m.dependencies.map{|d| d.name}]}]
      manifest_names = manifest_pairs.tsort
      manifest_names.map{|n| manifests[n]}
    end

  end
end