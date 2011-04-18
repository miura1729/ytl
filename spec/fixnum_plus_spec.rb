require 'ytlhelper'

describe "Fixnum#+" do
  it "returns self +plus the given positive Integer" do
    prog = "491 + 2"
    prog.execute_ytl.should == prog.execute_ruby
    prog = "90210 + 10"
    prog.execute_ytl.should == prog.execute_ruby
  end

  it "returns self +plus the given negative Integer" do
    prog = "491 + -2"
    prog.execute_ytl.should == prog.execute_ruby
    prog = "90210 + -10"
    prog.execute_ytl.should == prog.execute_ruby
    prog = "-90210 + -10"
    prog.execute_ytl.should == prog.execute_ruby
    prog = "-90210 + 10"
    prog.execute_ytl.should == prog.execute_ruby
  end
end
