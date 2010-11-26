module YTL
  include YTLJit
  
  def self.import_ruby_object(context)
    context.import_object(Object, :Array, Array) 
    context.import_object(Object, :String, String)
  end
end
  
