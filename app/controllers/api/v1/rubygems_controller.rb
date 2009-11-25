class Api::V1::RubygemsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create, :yank]

  before_filter :authenticate_with_api_key, :only => [:create, :yank]
  before_filter :verify_authenticated_user, :only => [:create, :yank]
  before_filter :find_gem,                  :only => [:show, :yank]

  def show
    if @rubygem.hosted?
      respond_to do |wants|
        wants.json { render :json => @rubygem }
        wants.xml  { render :xml  => @rubygem }
      end
    else
      render :text => "This gem does not exist.", :status => :not_found
    end
  end

  def create
    gemcutter = Gemcutter.new(current_user, request.body, request.host_with_port)
    gemcutter.process
    render :text => gemcutter.message, :status => gemcutter.code
  end

  def yank
    if @rubygem.hosted?
      begin
        version = Version.find_from_slug!(@rubygem, params[:version])
        version.destroy
        render :json => "Successfully yanked"
      rescue ActiveRecord::RecordNotFound
        render :json => "This gem could not be yanked.", :status => :forbidden
      end
    else
      render :json => "This gem does not exist.", :status => :not_found
    end
  end
end
