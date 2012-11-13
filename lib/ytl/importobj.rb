module YTL
  include YTLJit
  
  def self.import_ruby_object(context)
    context.import_object(Object, :Array, Array) 
    context.import_object(Object, :Hash, Hash) 
    context.import_object(Object, :String, String)
    context.import_object(Object, :Fixnum, Fixnum)
    context.import_object(Object, :Float, Float)
    context.import_object(Object, :Time, Time)
    context.import_object(Object, :File, File)
    context.import_object(Object, :IO, IO)
    context.import_object(Object, :Math, Math)
    context.import_object(Object, :Exception, Exception)
  end
end
  
