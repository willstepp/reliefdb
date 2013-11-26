class GuideController < ApplicationController
  def index
  end

  def results
    @relief_type = params[:relief_type]
    @location = params[:location].blank? ? [] : params[:location].split(';')
    @whoisit = params[:whoisit]
    @resources = params[:resource] ? params[:resource].keys : []
  end

  def map
  end

  def search
  end
end
