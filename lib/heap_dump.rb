require "heap_dump/version"

require 'rbconfig'
require "heap_dump.#{RbConfig::CONFIG['DLEXT']}"

module HeapDump
  # Dumps ruby object space to file
  def self.dump filename='dump.json', gc_before_dump=true
    GC.start if gc_before_dump
    return dump_ext(filename)
  end

  # provides an object count - like ObjectSpace.count_objects, but also for user classes
  def self.count_objects namespaces_array=[], gc=false
    unless namespaces_array.is_a?(Array) && namespaces_array.all?{|v|v.respond_to? :to_s}
      if namespaces_array.respond_to? :to_s
        namespaces_array = [namespaces_array.to_s]
      else
        #TODO: actually, better way is to accept anything convertable, even module itself
        raise ArgumentError.new("namespaces_array must be a symbol/string or array of strings/symbols")
      end
    end
    prefixes_array = namespaces_array.map{|c| c.to_s}
    return count_objects_ext(prefixes_array, !!gc)
  end
end
