class Facility < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization
  
  has_many :resources, :dependent => :destroy
  has_many :loads, :dependent => :destroy

  def self.nearest_to(lat, long, resource_type, tags, radius_in_miles = 100)
    q = haversine_query(lat, long, resource_type, tags, radius_in_miles)
    Rails.logger.info "Facility Haversine:"
    Rails.logger.info q
    ActiveRecord::Base.connection.execute(q)
  end

  def can_manage?(user)
    if user
      user.role?(:admin) or self.organization.users.include?(user)
    else
      false
    end
  end

  private

  #http://en.wikipedia.org/wiki/Haversine_formula
  def self.haversine_query(lat, long, resource_type, tags, radius_in_miles)
    %Q(
        SELECT distances.* FROM
          (SELECT id, name, address, latitude, longitude, (3959 * acos(cos(radians(#{lat})) * cos(radians(latitude)) *
                              cos(radians(longitude) - radians(#{long})) +
                              sin(radians(#{lat})) * sin(radians(latitude))))
          AS distance 
          FROM facilities
           ) AS distances
        #{filter_by_tags(resource_type, tags)}
        WHERE distance < #{radius_in_miles}
        GROUP BY distances.id,distances.name,distances.address,distances.latitude,distances.longitude,distances.distance
        ORDER BY distance
        OFFSET 0;
      )
  end

  def self.filter_by_tags(resource_type, tags)
    if tags.count > 0
      %Q(
        INNER JOIN resources r
        ON distances.id = r.facility_id AND r.resource_type = '#{resource_type}'
        INNER JOIN resources_tags rt
        ON r.id = rt.resource_id AND (#{tag_filters(tags)})
      )
    else
      ""
    end
  end

  def self.tag_filters(tags)
    filter = ""
    tags.each do |t|
      filter += "rt.tag_id=#{t}#{" OR " unless t == tags.last}" 
    end
    filter
  end
end
