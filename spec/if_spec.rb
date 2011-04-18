require 'ytlhelper'

describe "Fixnum#+" do
  it "evaluate body if expression is true" do
    prog = "a = []; if true then a = [123]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "does not evaluate body if expression is false" do
    prog = "a = []; if false then a = [123]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end
end
