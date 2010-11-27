module YTL
  include YTLJit
  
  def self.import_ruby_object(context)
    context.import_object(Object, :Array, Array) 
    context.import_object(Object, :String, String)
    context.import_object(Object, :Math, Math)
  end
end
  
