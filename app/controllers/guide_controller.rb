class GuideController < ApplicationController
  def index
  end

  def results
    @relief_type = params[:relief_type]
    @location = params[:location].blank? ? [] : params[:location].split(';')
    @whoisit = params[:whoisit]
    @resources = params[:resource] ? params[:resource].keys : []

    #first get list of unfiltered facilities in the radius
    @radius = 100
    @facilities = Facility.nearest_to(@location.first, @location.last, @radius)
  end

  def map
  end

  def search
  end
end
