require 'mkmf'


module GSL
	class Version
		def initialize(str)
			@str = str
			@ary = str.split(".").collect { |elm| elm.to_i }
		end
		def to_s; @str; end
		def inspect; @str; end
		def >=(ver)
			ary2 = ver.split(".").collect { |elm| elm.to_i }
			if @ary[0] > ary2[0]; return true; end			
			if @ary[0] < ary2[0]; return false; end
			if @ary[1] > ary2[1]; return true; end
			if @ary[1] < ary2[1]; return false; end
			if @ary.size < ary2.size; return false; end
			if @ary.size == 3 and ary2.size == 3
				if @ary[2] < ary2[2]; return false; end
			end		
			return true
		end
		def <(ver)
			ary2 = ver.split(".").collect { |elm| elm.to_i }
			if @ary[0] >= ary2[0]; return false; end
			if @ary[0] >= ary2[0]; return false; end
			return true
		end
	end
end

if /mingw/ =~ RUBY_PLATFORM
  GSL_CONFIG = "sh gsl-config"
else
  GSL_CONFIG = "gsl-config"
end

def gsl_config()
  print("checking gsl cflags... ")
  IO.popen("#{GSL_CONFIG} --cflags") do |f|
    cflags = f.gets.chomp
    puts(cflags)
    $CFLAGS += " " + cflags
  end
   
  IO.popen("#{GSL_CONFIG} --libs") do |f|
    libs = f.gets.chomp
    dir_config("cblas")
    dir_config("atlas")
    if have_library("cblas") and have_library("atlas")
      libs.gsub!("-lgslcblas", "-lcblas -latlas")
      $LOCAL_LIBS += " " + libs.gsub(" -lgslcblas", "")
      print("checking gsl libs... ")
      puts(libs)
    else
      print("checking gsl libs... ")
      puts(libs)
      $LOCAL_LIBS += " " + libs
    end
  end

end

def check_version(configfile)
  
  print("checking gsl version... ")
  IO.popen("#{GSL_CONFIG} --version") do |f|
    ver = GSL::Version.new(f.gets.chomp)
    puts(ver)
    configfile.printf("#ifndef GSL_VERSION\n#define GSL_VERSION \"#{ver}\"\n#endif\n")

    if ver >= "0.9.4"
      configfile.printf("#ifndef GSL_0_9_4_LATER\n#define GSL_0_9_4_LATER\n#endif\n")
    else
      configfile.close
      raise("Ruby/GSL requires gsl-0.9.4 or later.")
    end
    if ver >= "1.0"
      configfile.printf("#ifndef GSL_1_0_LATER\n#define GSL_1_0_LATER\n#endif\n")
    end
    if ver >= "1.1"
      configfile.printf("#ifndef GSL_1_1_LATER\n#define GSL_1_1_LATER\n#endif\n")
    end
    if ver >= "1.1.1"
      configfile.printf("#ifndef GSL_1_1_1_LATER\n#define GSL_1_1_1_LATER\n#endif\n")
    end
    if ver >= "1.2"
      configfile.printf("#ifndef GSL_1_2_LATER\n#define GSL_1_2_LATER\n#endif\n")
    end
    if ver >= "1.3"
      configfile.printf("#ifndef GSL_1_3_LATER\n#define GSL_1_3_LATER\n#endif\n")
    end
    if ver >= "1.4"
      configfile.printf("#ifndef GSL_1_4_LATER\n#define GSL_1_4_LATER\n#endif\n")
    end
    if ver >= "1.4.90"
      configfile.printf("#ifndef GSL_1_4_9_LATER\n#define GSL_1_4_9_LATER\n#endif\n")
    end
    
    if ver >= "1.5.90"
      configfile.printf("#ifndef GSL_1_6_LATER\n#define GSL_1_6_LATER\n#endif\n")
    end

    if ver >= "1.7.90"
      configfile.printf("#ifndef GSL_1_8_LATER\n#define GSL_1_8_LATER\n#endif\n")
    end
    if ver >= "1.8.90"
      configfile.printf("#ifndef GSL_1_9_LATER\n#define GSL_1_9_LATER\n#endif\n")
    end

    if ver >= "1.9.90"
      configfile.printf("#ifndef GSL_1_10_LATER\n#define GSL_1_10_LATER\n#endif\n")
    end    
    if ver < "1.4"
      configfile.printf("#ifndef GSL_CONST_OLD\n#define GSL_CONST_OLD\n#endif\n")
    end

  end
end

#####

$CFLAGS = " -Wall -I../include"

begin
  RB_GSL_CONFIG = File.open("../include/rb_gsl_config.h", "w")
  RB_GSL_CONFIG.printf("#ifndef ___RB_GSL_CONFIG_H___\n")
  RB_GSL_CONFIG.printf("#define ___RB_GSL_CONFIG_H___\n\n")

  check_version(RB_GSL_CONFIG)

  gsl_config()

  have_func("round")

# Check GSL extensions

  if have_header("rngextra/rngextra.h")
    have_library("rngextra")
  end

  if have_header("qrngextra/qrngextra.h")
    have_library("qrngextra")
  end

  if have_header("ool/ool_version.h")
    have_library("ool")
  end
  
  if have_header("gsl_tensor/gsl_tensor.h")
    have_library("gsltensor")
  end
 
  if have_header("jacobi.h")
    have_library("jacobi")
  end
  if have_header("gsl/gsl_cqp.h")
    have_library("cqp")
  end
  if have_header("gsl/gsl_multimin_fsdf.h")
    have_library("bundle_method")
  end
     
  if have_library("gsl", "gsl_poly_solve_quartic")
    RB_GSL_CONFIG.printf("#ifndef HAVE_POLY_SOLVE_QUARTIC\n#define HAVE_POLY_SOLVE_QUARTIC\n#endif\n")
  end
  if have_library("gsl", "gsl_eigen_francis")
    RB_GSL_CONFIG.printf("#ifndef HAVE_EIGEN_FRANCIS\n#define HAVE_EIGEN_FRANCIS\n#endif\n")
  end

	if have_header("ndlinear/gsl_multifit_ndlinear.h")
		have_library("ndlinear")
	end
	
  begin
    print("checking rb-gsl version...")
    IO.popen("cat ../VERSION") do |f|
      ver = GSL::Version.new(f.gets.chomp)
      puts(ver)
      RB_GSL_CONFIG.printf("#ifndef RUBY_GSL_VERSION\n#define RUBY_GSL_VERSION \"#{ver}\"\n#endif\n")
    end
  end

  RUBY_VERSION2 = GSL::Version.new(RUBY_VERSION)
  
  puts("checking ruby version... #{RUBY_VERSION2}")
  if RUBY_VERSION2 >= "1.8"
    RB_GSL_CONFIG.printf("#ifndef RUBY_1_8_LATER\n#define RUBY_1_8_LATER\n#endif\n")

    if find_executable("graph")
      RB_GSL_CONFIG.printf("#ifndef HAVE_GNU_GRAPH\n#define HAVE_GNU_GRAPH\n#endif\n")
    end
  else
    path = (path || ENV['PATH']).split(File::PATH_SEPARATOR)  
    flag = 0
    print("checking for GNU graph... ")
    path.each do |dir|    
      if File.executable?(file = File.join(dir, "graph")) 
        puts("yes")
        RB_GSL_CONFIG.printf("#ifndef HAVE_GNU_GRAPH\n#define HAVE_GNU_GRAPH\n#endif\n")
        flag = 1
        break
      end
    end
    puts("no") if flag == 0
  end
  if RUBY_VERSION2 >= "1.9"
    RB_GSL_CONFIG.printf("#ifndef RUBY_1_9_LATER\n#define RUBY_1_9_LATER\n#endif\n")
  end

  RB_GSL_CONFIG.printf("\n#endif\n")
  RB_GSL_CONFIG.close
  
rescue
  raise("Check GSL>=0.9.4 is installed, and the command \"gsl-config\" is in search path.")
end

#narray_config = dir_config("narray")
narray_config = dir_config('narray',$sitearchdir,$sitearchdir)
have_narray_h = have_header("narray.h")
if narray_config
  if RUBY_PLATFORM =~ /cygwin|mingw/
#    have_library("narray") || raise("ERROR: narray import library is not found") 
  have_library("narray")
  end
end

tamu_anova_config = dir_config('tamu_anova',$sitearchdir,$sitearchdir)
have_tamu_anova_h = have_header("tamu_anova/tamu_anova.h")
if tamu_anova_config
  have_library("tamuanova")
#  if RUBY_PLATFORM =~ /cygwin|mingw/
#    have_library("tamuanova") || raise("ERROR: tamu_anova import library is not found")
#  end
end

File.open("../lib/gsl.rb", "w") do |file|
  if have_narray_h
    file.print("require\(\"narray\"\)\n")
  end
#  file.print("require\(\"rb_gsl\"\)\ninclude GSL\n")
  file.print("require\(\"rb_gsl\"\)\n")  
  file.print("require\(\"gsl/oper.rb\"\)\n")
end

File.open("../lib/rbgsl.rb", "w") do |file|
  if have_narray_h
    file.print("require\(\"narray\"\)\n")
  end
  file.print("require\(\"rb_gsl\"\)\n")
  file.print("require\(\"gsl/oper.rb\"\)\n")
end

srcs = Dir.glob("*.c") - ["vector_source.c", "matrix_source.c", "tensor_source.c", "poly_source.c", "block_source.c"]

$objs = srcs.collect { |f| f.sub(".c", ".o") }

create_makefile("rb_gsl")
