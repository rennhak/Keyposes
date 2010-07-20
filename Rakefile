$:.unshift(File.dirname(__FILE__) + '/../../lib')


require 'cucumber/rake/task'
require 'spec/rake/spectask'


desc "Default Task - Run cucumber and rspec with rcov"
task :all => [ "rcov:all" ]

desc "Run Cucumber"
Cucumber::Rake::Task.new

# Include RCOV
namespace :rcov do # {{{

  desc "Run Cucumber Features"
  Cucumber::Rake::Task.new( :cucumber ) do |t|
    t.rcov = true
    t.rcov_opts = %w{--aggregate coverage.info}
    t.rcov_opts << %[-o "coverage"]
    t.cucumber_opts = %w{--format pretty}
  end


  Spec::Rake::SpecTask.new(:rspec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    #t.rcov_opts = lambda do
    #  IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    #end
  end

  desc "Run both specs and features to generate aggregated coverage"
  task :all do |t|
    rm "coverage.info" if File.exist?("coverage.info")
    Rake::Task['rcov:rspec'].invoke
    Rake::Task["rcov:cucumber"].invoke
    # Rake::Task["flog"].invoke
    # Rake::Task["flay"].invoke
  end


end # of namespace :rcov }}}

desc "Clean up temporary data"
task :clean do |t|
  `rm coverage.info` if( File.exists?( "coverage.info" ) )
  `rm -rf coverage`  if( File.exists?( "coverage" ) )
  `rm -rf .yardoc`   if( File.exists?( ".yardoc" ) )
  if( File.exists?( "doc" ) )
    Dir.chdir( "doc" ) do 
      `rm -rf yardoc`  if( File.exists?( "yardoc" ) )
    end
  end
  `rm -rf src/BodyComponents/*.gp`
  `rm -rf src/BodyComponents/*.gpdata`
  `rm -rf src/BodyComponents/*.eps`
  `rm -f  src/BodyComponents/work/*.csv`
end

desc "Flog the code"
task :flog do |t|
  files = Dir["**/*.rb"]
  files.collect! { |f| (  f =~ %r{archive|features|spec}i ) ? ( next ) : ( f )  }
  files.compact!
  files.each do |f|
    puts ""
    puts "#######"
    puts "# #{f}"
    puts "################"
    system "flog #{f}"
    puts ""
  end
end

desc "Flay the code"
task :flay do |t|
  files = Dir["**/*.rb"]
  files.collect! { |f| (  f =~ %r{archive|features|spec}i ) ? ( next ) : ( f )  }
  files.compact!
  files.each do |f|
    puts ""
    puts "#######"
    puts "# #{f}"
    puts "################"
    system "flay #{f}"
    puts ""
  end
end

desc "Generate Yardoc documentation"
task :yardoc do |t|
  `yardoc -o doc/yardoc`
end


# cucumber --format usage
# cucover
# autotest
# spork
# testjour
#   distribute over cores or machines


