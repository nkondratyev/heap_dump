#!/usr/bin/env ruby
#encoding: utf-8

require 'mkmf'
require 'debugger/ruby_core_source'

def find_spec name,*requirements
  return Gem::Specification.find_by_name(name, *requirements) if Gem::Specification.respond_to? :find_by_name

  requirements = Gem::Requirement.default if requirements.empty?

  gem = Gem::Dependency.new(name, *requirements)
  matches = Gem.source_index.find_name(gem.name, gem.requirement)
  raise "No matching #{name} gem!" unless matches.any?
  matches.find { |spec|
    Gem.loaded_specs[gem.name] == spec
    } or matches.last
end

def find_gem_dir(name, *req)
  gem = find_spec(name, *req)
  return gem.gem_dir if gem.respond_to? :gem_dir
  gem.full_gem_path
end


gemspec = File.expand_path(File.join(File.dirname(__FILE__), '../../heap_dump.gemspec'))
spec = instance_eval(File.read(gemspec), gemspec).dependencies.find{|d|d.name == 'yajl-ruby'}
#$defs.push(format("-DREQUIRED_YAJL_VERSION=\\"%s\\"", spec.requirement)) #does not work in this form :(

yajl = find_gem_dir(spec.name, spec.requirement)
find_header('api/yajl_gen.h', File.join(yajl, 'ext', 'yajl'))


hdrs = proc {
  res = %w{
    vm_core.h
    iseq.h
    node.h
    method.h
  }.all?{|hdr| have_header(hdr)}
  # atomic.h
  # constant.h

  #optional:
  %w{
    constant.h
    }.each{|h| have_header(h)}

  res
}

dir_config("ruby") # allow user to pass in non-standard core include directory

if !Debugger::RubyCoreSource::create_makefile_with_core(hdrs, "heap_dump")
  exit(1)
end
