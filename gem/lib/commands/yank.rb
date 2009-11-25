
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
    add_version_option
  end

  def execute
    setup
    # raise options.inspect
    yank_gem(options[:version])
  end

  def yank_gem(version)
    say "Yanking gem from Gemcutter..."

    name = get_one_gem_name
    url = "gems/yank/#{name}"
    # say "posting to #{url}"

    response = make_request(:delete, url) do |request|
      request.add_field("Authorization", api_key)
      request.set_form_data({'version' => version})
    end
    
    say response.body
  end

end
