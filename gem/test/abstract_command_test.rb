require 'command_helper'

class Gem::Commands::FakeCommand < Gem::AbstractCommand
  def description
    'fake command'
  end

  def initialize
    super 'fake', description
  end

  def execute
  end
end

class AbstractCommandTest < CommandTest
  context "with an fake command" do
    setup do
      @command = Gem::Commands::FakeCommand.new
      stub(@command).say
      ENV['http_proxy'] = nil
      ENV['HTTP_PROXY'] = nil
    end

    context "parsing the proxy" do
      should "return nil if no proxy is set" do
        stub(Gem).configuration { { :http_proxy => nil } }
        assert_equal nil, @command.http_proxy
      end

      should "return nil if the proxy is set to :no_proxy" do
        stub(Gem).configuration { { :http_proxy => :no_proxy } }
        assert_equal nil, @command.http_proxy
      end

      should "return a proxy as a URI if set" do
        stub(Gem).configuration { { :http_proxy => 'http://proxy.example.org:9192' } }
        assert_equal 'proxy.example.org', @command.http_proxy.host
        assert_equal 9192, @command.http_proxy.port
      end

      should "return a proxy as a URI if set by environment variable" do
        ENV['http_proxy'] = "http://jack:duck@192.168.1.100:9092"
        assert_equal "192.168.1.100", @command.http_proxy.host
        assert_equal 9092, @command.http_proxy.port
        assert_equal "jack", @command.http_proxy.user
        assert_equal "duck", @command.http_proxy.password
      end
    end

    # TODO: rewrite all of this junk using spies
    #should "use a proxy if specified" do
    #  stub(@command).http_proxy { 'http://some.proxy' }
    #  mock(@command).use_proxy!
    #  mock(@command).sign_in
    #  @command.setup
    #end

    #should "not use a proxy if unspecified" do
    #  stub(@command).http_proxy { nil }
    #  mock(@command).use_proxy!.never
    #  mock(@command).sign_in
    #  @command.setup
    #end

    should "sign in if no api key" do
      stub(Gem).configuration { {:gemcutter_key => nil} }
      mock(@command).sign_in
      @command.setup
    end

    should "not sign in if api key exists" do
      stub(Gem).configuration { {:gemcutter_key => "1234567890"} }
      mock(@command).sign_in.never
      @command.setup
    end

    context "using the proxy" do
      setup do
        stub(Gem).configuration { { :http_proxy => "http://gilbert:sekret@proxy.example.org:8081" } }
        @proxy_class = Object.new
        mock(Net::HTTP).Proxy('proxy.example.org', 8081, 'gilbert', 'sekret') { @proxy_class }
        @command.use_proxy!
      end

      should "replace Net::HTTP with a proxy version" do
        assert_equal @proxy_class, @command.proxy_class
      end
    end

    context "signing in" do
      setup do
        @email = "email"
        @password = "password"
        @key = "key"
        mock(@command).say("Enter your Gemcutter credentials. Don't have an account yet? Create one at #{Gem::AbstractCommand::URL}/sign_up")
        mock(@command).ask("Email: ") { @email }
        mock(@command).ask_for_password("Password: ") { @password }
        FakeWeb.register_uri :get, "https://#{@email}:#{@password}@#{gemcutter_domain}/api_key", :body => @key

        @config = Object.new
        stub(Gem).configuration { @config }
        stub(@config)[:gemcutter_key] = @key
        stub(@config).write
      end

      should "sign in" do
        mock(@command).say("Signed in. Your api key has been stored in ~/.gemrc")
        @command.sign_in
      end

      should "let the user know if there was a problem" do
        @problem = "Access Denied"
        mock(@command).say(@problem)
        mock(@command).terminate_interaction
        mock(@config).write.never

        FakeWeb.register_uri :get, "https://#{@email}:#{@password}@#{gemcutter_domain}/api_key", :body => @problem, :status => 401
        @command.sign_in
      end
    end
  end
end
