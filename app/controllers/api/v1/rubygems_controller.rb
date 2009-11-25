class Api::V1::RubygemsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create

  before_filter :authenticate_with_api_key, :only => :create
  before_filter :verify_authenticated_user, :only => :create
  before_filter :find_gem,                  :only => [:show, :revert]

  def show
    if @rubygem.hosted?
      render :json => @rubygem.to_json
    else
      render :json => "This gem does not exist.", :status => :not_found
    end
  end

  def create
    gemcutter = Gemcutter.new(current_user, request.body)
    gemcutter.process
    render :text => gemcutter.message, :status => gemcutter.code
  end

  def revert
    if @rubygem.hosted?
      if @rubygem.revert!
        render :json => "Successfully reverted"
      else
        render :json => "This gem could not be reverted.", :status => :forbidden
      end
    else
      render :json => "This gem does not exist.", :status => :not_found
    end
  end
end
