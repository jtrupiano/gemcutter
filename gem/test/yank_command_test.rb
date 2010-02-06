require 'command_helper'

class YankCommandTest < CommandTest
  context "yanking" do
    setup do
      @command = Gem::Commands::YankCommand.new
      stub(@command).say
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
      url = "#{gemcutter_url}/api/v1/gems/yank/MyGem"

      mock(@command).say
      stub_config({ :rubygems_api_key => "key" })
      stub(@command).options { {:args => ["MyGem"]} }
      stub_request(:delete, url).to_return(:body => "Unable to yank gem")
      @command.invoke("MyGem")
      
      assert_received(@command) { |command| command.say("Yanking gem from Gemcutter...") }
      assert_received(@command) { |command| command.say("Unable to yank gem") }
    end
    
    should "yank a gem" do
      url = "#{gemcutter_url}/api/v1/gems/yank/MyGem"
      
      mock(@command).say("Yanking gem from Gemcutter...")
      stub(@command).options { {:args => ["MyGem"], :version => version_requirement} }
      stub_config({ :rubygems_api_key => "key" })
      stub_request(:delete, url).to_return(:body => "Successfully yanked")
    
      @command.yank_gem(version_requirement)
      assert_received(@command) { |command| command.say("Yanking gem from Gemcutter...") }
      assert_received(@command) { |command| command.say("Successfully yanked") }
    end
  end
  
  private
    def version_requirement
      Gem::Requirement.new(Gem::Version.new("0.1.0"))
    end
end
