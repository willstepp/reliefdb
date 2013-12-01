class GuideController < ApplicationController
  def index
    @tags = Tag.all.limit(5)
  end

  def results
    @relief_type = params[:relief_type] == 'need' ? 'Surplus' : 'Need'
    @location = params[:location].blank? ? [] : params[:location].split(';')
    @whoisit = params[:whoisit]
    @tag_keys = params[:tag] ? params[:tag].keys : ["1", "2", "3", "4", "5"]
    @tags = Tag.find(@tag_keys)

    @radius = 100

    @facilities = Facility.nearest_to(@location.first, @location.last, @relief_type, @tag_keys, @radius)
  end

  def map
  end

  def search
  end
end
