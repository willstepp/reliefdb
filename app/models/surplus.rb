class Surplus < Condition
  set_primary_key :id 
  def qty
    begin
      surplus_individual.to_i || 0
    rescue
      return 0
    end
  end
  def qty=(n)
    write_attribute("surplus_individual", n)
  end
end
