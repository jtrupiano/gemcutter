require 'command_helper'

class YankCommandTest < CommandTest
  context "yanking" do
    setup do
      @command = Gem::Commands::YankCommand.new
      stub(@command).say
      FakeWeb.register_uri :delete, "https://gemcutter.heroku.com/gems/yank/SomeGem", :body => "Successfully yanked"
    end

    should "setup and yank the gem" do
      mock(@command).setup
      mock(@command).yank_gem(version_requirement)
      @command.invoke("SomeGem", "-v0.1.0")
    end

    should "raise an error with no arguments" do
      assert_raise Gem::CommandLineError do
        @command.invoke
      end
    end
    
    should "cowardly refuse to yank a gem without a version" do
      @response = "Unable to yank gem"
      FakeWeb.register_uri :delete, "#{gemcutter_url}/gems/yank/MyGem", :body => @response
      mock(@command).say(@response)
      @command.invoke("MyGem")
    end
    
    should "yank a gem" do
      mock(@command).say("Yanking gem from Gemcutter...")
      @response = "Successfully yanked"
      FakeWeb.register_uri :delete, "#{gemcutter_url}/gems/yank/MyGem", :body => @response
    
      @gem = "MyGem"
      @config = { :gemcutter_key => "key" }
    
      stub(@command).options { {:args => [@gem], :version => version_requirement} }
      stub(Gem).configuration { @config }
    
      mock(@command).say(@response)
      @command.yank_gem(version_requirement)
    end
  end
  
  private
    def version_requirement
      Gem::Requirement.new(Gem::Version.new("0.1.0"))
    end
end
