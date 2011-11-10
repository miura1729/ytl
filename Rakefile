#

require "rbconfig"
require "benchmark"

ruby_bin = File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])
BENCH_DIR = "c:/cygwin/home/miura/src/ruby-trunk/ruby/benchmark/"
#BENCH_DIR = "~/cygwin/src/ruby-trunk/ruby/benchmark/"

desc "run tests"

task :test do
  Dir.glob(File.join("test", "*.rb")) do |f|
    sh "#{ruby_bin} -I../ytljit/ext -I../ytljit/lib -I lib/ lib/ytl.rb -r runtime/type.rb " + f
  end
end

cnt = 0
task :bench do
  ["bm_so_binary_trees.rb", "bm_so_matrix.rb", "bm_so_array.rb",
   "bm_so_ackermann.rb", "bm_so_concatenate.rb", "bm_so_random.rb", 
   "bm_so_object.rb", "bm_so_nested_loop.rb", "bm_so_sieve.rb", 
   "bm_so_partial_sums.rb", "bm_so_mandelbrot.rb", "bm_so_nbody.rb", 
   "bm_so_nsieve.rb", "bm_so_count_words.rb", "bm_so_fannkuch.rb", 
   "ao-render.rb", "bm_app_pentomino.rb" 
  ].each do |f|
    fn = File.join(BENCH_DIR, f)
    Benchmark.benchmark(
      " " * 13 + "     user     system      total      real \n", 13,
      "%10.6U %10.6Y %10.6t %10.6r\n"
                        ) do |x|
      print "#{f} \n"
      x.report("ytl         "){ system "ytl #{fn} > /dev/null" }
      x.report("ytl compile "){ system "ytl --compile-only #{fn} > /dev/null" }
      if cnt < 16 then
        x.report("ytl unboxed "){ system "ytl --compile-array-as-unboxed #{fn} > /dev/null" }
      end
      x.report("ruby        "){ system "ruby #{fn} > /dev/null" }
      cnt += 1
    end
  end
end

task :default => [:test]
