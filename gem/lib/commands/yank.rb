class Gem::Commands::YankCommand < Gem::AbstractCommand

  def description
    'Remove a specific gem version release from Gemcutter'
  end

  def arguments
    "GEM       name of gem"
  end

  def usage
    "#{program_name} GEM -v VERSION"
  end

  def initialize
    super 'yank', description
    add_option('-v', '--version VERSION', 'Version to remove') do |value, options|
      options[:version] << value
    end
  end

  def execute
    setup
    yank_gem(options[:version])
  end

  def yank_gem(version)
    say "Yanking gem from Gemcutter..."

    name = get_one_gem_name
    response = make_request(:post, "gems/yank/#{name}?version=#{version}") do |request|
      request.add_field("Authorization", api_key)
    end

    say response.body
  end

end
