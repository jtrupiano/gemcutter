require 'command_helper'

class YankCommandTest < CommandTest
  context "yanking" do
    setup do
      @command = Gem::Commands::YankCommand.new
      stub(@command).say
      FakeWeb.register_uri :post, "https://gemcutter.heroku.com/gems/yank/SomeGem", :body => "Successfully yanked"
    end

    should "setup and yank the gem" do
      mock(@command).setup
      mock(@command).yank_gem("0.1.0")
      @command.invoke("SomeGem")
    end

    # should "raise an error with no arguments" do
    #   assert_raise Gem::CommandLineError do
    #     @command.yank_gem
    #   end
    # end
    # 
    # should "yank a gem" do
    #   mock(@command).say("Yanking gem from Gemcutter...")
    #   @response = "Successfully yanked"
    #   FakeWeb.register_uri :post, "https://gemcutter.heroku.com/gems/test?version=0.1.0", :body => @response
    # 
    #   @gem = "test"
    #   @config = { :gemcutter_key => "key" }
    # 
    #   stub(@command).options { {:args => [@gem], :version => '0.1.0'} }
    #   stub(Gem).configuration { @config }
    # 
    #   mock(@command).say(@response)
    #   @command.yank_gem('0.1.0')
    # end
  end
end
