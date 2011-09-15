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
  `rm -rf src/BodyComponents/graphs/*.gp`
  `rm -rf src/BodyComponents/graphs/*.gpdata`
  `rm -rf src/BodyComponents/graphs/*.eps`
  `rm -f  src/BodyComponents/work/*.csv`
end

desc "Generate eps from gnuplot gp files"
task :gnuplot do |t|
  Dir.chdir( "src/BodyComponents/graphs" ) do |d|
    Dir["*.gp"].each do |g|
      `gnuplot #{g.to_s}`
    end
  end
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


desc "Generate proper README via m4"
task :readme do |t|
  sh "m4 m4/README.m4 > README"
end


# cucumber --format usage
# cucover
# autotest
# spork
# testjour
#   distribute over cores or machines

desc "Generate an all component graph for a given dance"
task :graph, :config_name do |g, args|

  Dir.chdir( "src/BodyComponents" ) do

    boxcar      = 20

    components  = []

    components << %w[upper_arms 4]
    components << %w[thighs 4]

    components << %w[shanks 8]
    components << %w[fore_arms 8]
    components << %w[upper_arms  8]
    components << %w[thighs 8]

    components << %w[feet 12]
    components << %w[hands 12]
    components << %w[shanks 12]
    components << %w[fore_arms 12]
    components << %w[upper_arms 12]
    components << %w[thighs 12]


    # Get rid of previous compilations
    `rm -rf experiment`
    `mkdir experiment`

    puts ""

    # Generate components and shift to experiment folder
    components.each do |part, model|

      %w[both].each do |side|

        printf( "[%s] Calculating ->  Side: %-6s part: %-10s model: %3s\n", args.config_name.to_s, side.to_s, part.to_s, model.to_s )

        `rake clean`
        `ruby -I../../base/MotionX/src/plugins/vpm/src Controller.rb -tc -p #{args.config_name.to_s} -b #{boxcar.to_s} --parts #{part.to_s} -m #{model.to_s} -v -s #{side.to_s}`
        `rake gnuplot`

        model_dir   = ( model.to_i < 10 ) ? ( "0" + model.to_s ) : ( model.to_s )
        target_dir  = "experiment/model_#{model_dir.to_s}/#{side.to_s}/#{part.to_s}"
        `mkdir -p #{target_dir}`
        `mv graphs/* #{target_dir}`

      end # of %w[both].each
    end # of components.each 

  end
end

desc "Generate cTags"
task :ctags do |t|
  `ctags -R Rakefile src/BodyComponents/*.rb`
end 

desc "Generate an all component graph for a given dance"
task :graph_gen, :config_name do |g, args|

  Dir.chdir( "src/BodyComponents" ) do

    boxcar      = 20

    components  = []

    components << %w[upper_arms 4]
    components << %w[thighs 4]

    components << %w[shanks 8]
    components << %w[fore_arms 8]
    components << %w[upper_arms  8]
    components << %w[thighs 8]

    components << %w[feet 12]
    components << %w[hands 12]
    components << %w[shanks 12]
    components << %w[fore_arms 12]
    components << %w[upper_arms 12]
    components << %w[thighs 12]


    # Copy template files
    `cp -vrap template/* experiment/.`

    # Generate frames with moving line to indicate position
    frames_filename = `find | egrep -i "frenet_frame_kappa_plot.gpdata" | head -1`
    frame_begin     = `head -1 #{frames_filename.to_s}`.split( " " ).first
    frame_end       = `tail -1 #{frames_filename.to_s}`.split( " " ).first

    Dir.chdir( "experiment" ) do

      `mkdir -p animation_heatmap`

      frame_begin.to_i.upto( frame_end.to_i ).each do |i|
        puts "[Heatmap] Processing frame #{i.to_s} of #{frame_end.to_s}"
        `cat line.gpdata.orig | sed "s/x/#{i.to_s}/g" > line.gpdata`
        `gnuplot heatmap.gp`

        #`convert frame.eps frame.jpg`
        #`mv frame.jpg animation_heatmap/#{i.to_s}.jpg`
        #`rm frame.eps`

        `mv frame.eps animation_heatmap/#{i.to_s}.eps`
      end

      `mkdir -p animation_curves`

      frame_begin.to_i.upto( frame_end.to_i ).each do |i|
        puts "[Curves] Processing frame #{i.to_s} of #{frame_end.to_s}"
        `cat line.gpdata.orig | sed "s/x/#{i.to_s}/g" > line.gpdata`
        `gnuplot curves.gp`
        `convert frame.eps frame.jpg`
        `mv frame.jpg animation_curves/#{i.to_s}.jpg`
        `rm frame.eps`
      end

      `mkdir -p video_frames`
      puts ""
      puts "Please put the corresponding video frames images into the video_frames folder (#{Dir.pwd.to_s}/video_frames/) and press ENTER"
      STDIN.gets

      # Rename images from motion viewer from 000.jpg -> 0.jpg etc.
      Dir.chdir( "video_frames" ) do 
        `autoload zmv`
        `zmv '0##(?*).png' '$1.png'`
      end # of Dir.chdir( "video_frames" )

      # Merge video and heatmap/curve map
      `mkdir -p animation_heatmap_merged`

      Dir.chdir( "animation_heatmap_merged" ) do
        frame_begin.to_i.upto( frame_end.to_i ).each do |i|
          puts "[Heatmap] Merging video and heatmap frame to one image -> frame #{i.to_s} of #{frame_end.to_s}"
          `convert -gravity center ../video_frames/#{i.to_s}.png -gravity center ../animation_heatmap/#{i.to_s}.eps +append -quality 100 -gravity center  p#{i.to_s}.jpg`
          `convert p#{i.to_s}.jpg -resize 1920x1080 #{i.to_s}.jpg`
          `rm -f p#{i.to_s}.jpg`
        end 
      end # of Dir.chdir( "animation_heatmap_merged" )

#      `rm -rf animation_heatmap`
      name = args.config_name.to_s + "_-_" + "heatmap.avi"
      ffmpeg_command = "ffmpeg -qscale 1 -r 20 -b 9600 -i animation_heatmap_merged/%d.jpg #{name.to_s}"
      `#{ffmpeg_command}`
#      `rm -rf animation_heatmap_merged`


      # Merge video and heatmap/curve map
      `mkdir -p animation_curves_merged`

      Dir.chdir( "animation_curves_merged" ) do
        frame_begin.to_i.upto( frame_end.to_i ).each do |i|
          puts "[Curves] Merging video and curves frame to one image -> frame #{i}"
          `convert -gravity center ../video_frames/#{i.to_s}.png -gravity center ../animation_curves/#{i.to_s}.eps +append -quality 100 -gravity center  p#{i.to_s}.jpg`
          `convert p#{i.to_s}.jpg -resize 1920x1080 #{i.to_s}.jpg`
          `rm -f p#{i.to_s}.jpg`
        end 
      end # of Dir.chdir( "animation_heatmap_merged" )

#      `rm -rf animation_curves`
      name = args.config_name.to_s + "_-_" + "curves.avi"
      ffmpeg_command = "ffmpeg -qscale 1 -r 20 -b 9600 -i animation_curves_merged/%d.jpg #{name.to_s}"
      `#{ffmpeg_command}`
#      `rm -rf animation_curves_merged`

    end # of Dir.chdir( "experiment" )

  end # of Dir.chdir
end # of task





