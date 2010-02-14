# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{progress-monitor}
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Miguel Vazquez"]
  s.date = %q{2010-02-14}
  s.description = %q{Patches some each and collect functions of certain classes (Array, Hash, Integer) to report progress}
  s.email = %q{miguel.vazquez@fdi.ucm.es}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "lib/progress-monitor.rb",
     "samples/announce.rb",
     "samples/announce_monitor.rb",
     "samples/collect.rb",
     "samples/depth.rb",
     "samples/file.rb",
     "samples/hash-loop.rb",
     "samples/skip.rb",
     "samples/times.rb",
     "samples/two-loops.rb"
  ]
  s.homepage = %q{http://github.com/mikisvaz/progress-monitor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Monitor Progress in the Command Line}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

