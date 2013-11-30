class Facility < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization
  
  has_many :resources, :dependent => :destroy
  has_many :loads, :dependent => :destroy

  def self.nearest_to(lat, long, radius_in_miles = 100)
    ActiveRecord::Base.connection.execute(haversine_query(lat, long, radius_in_miles))
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
  def self.haversine_query(lat, long, radius_in_miles)
    %Q(
        SELECT * FROM
          (SELECT id, name, address, latitude, longitude, (3959 * acos(cos(radians(#{lat})) * cos(radians(latitude)) *
                              cos(radians(longitude) - radians(#{long})) +
                              sin(radians(#{lat})) * sin(radians(latitude))))
           AS distance
           FROM facilities) AS distances
        WHERE distance < #{radius_in_miles}
        ORDER BY distance
        OFFSET 0;
      )
  end
end
