#

require "rbconfig"
require "benchmark"

ruby_bin = File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])

desc "run tests"

task :test do
  Dir.glob(File.join("test", "*.rb")) do |f|
    sh "#{ruby_bin} -I../ytljit/ext -I../ytljit/lib -I lib/ lib/ytl.rb -r runtime/type.rb " + f
  end
end

task :bench do
  ["bm_so_object.rb", "bm_so_nested_loop.rb", "bm_so_nbody.rb", 
   "bm_so_binary_trees.rb", "bm_so_matrix.rb", "bm_so_mandelbrot.rb", 
   "bm_app_pentomino.rb", "ao-render.rb"
   ].each do |f|
    fn = File.join("c:/cygwin/home/miura/src/ruby-trunk/ruby/benchmark/", f)
    Benchmark.bm do |x|
      print "#{f} \n"
      x.report("ytl         "){ system "ruby c:/cygwin/usr/local/bin/ytl #{fn} > /dev/null" }
#      x.report("ytl unboxed "){ system "ruby c:/cygwin/usr/local/bin/ytl --compile-array-as-unboxed #{fn} > /dev/null" }
      x.report("ruby        "){ system "ruby #{fn} > /dev/null" }
    end
  end
end

task :default => [:ext, :test]
