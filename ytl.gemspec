spec = Gem::Specification.new do |s|
     s.platform     = Gem::Platform::RUBY
     s.name         = "ytl"
     s.version      = "0.0.5"
     s.summary      = "Very tiny subset of YARV to native code translator"
     s.authors      = ["Hideki Miura"]
     s.files        = [*Dir.glob("{lib}/*.rb"),
                       *Dir.glob("{lib}/ytl/*.rb"),
                       *Dir.glob("{runtime}/*.rb"),
                       *Dir.glob("{test}/*.rb"), 
                       *Dir.glob("{bin}/ytl"), 
		       "README"]
     s.require_path = "lib"
     s.executables  = ['ytl']
     s.test_files   =	Dir.glob("{test}/*.rb")
     s.add_dependency('ytljit', [">= 0.0.7"])
end
