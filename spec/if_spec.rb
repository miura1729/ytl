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

  it "does not evaluate body if expression is false" do
    prog = "a = []; if false then a = [123]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "does not evaluate body if expression is true" do
    prog = "a = []; if () then a = [123]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "does not evaluate else-body if expression is true" do
    prog = "a = []; if true then a = [123]; else [456]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "evaluate only else-body if expression is false" do
    prog = "a = []; if false then a = [123]; else [456]; end; a"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "returns result of then-body evaluation if expression is true" do
    prog = "if true then 123 end"
    prog.execute_ytl.should == prog.execute_ruby
  end
end
