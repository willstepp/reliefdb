module SheltersHelper
  def region_or_state(shelter)
    shelter.region != '' ? region_link(shelter) : (shelter.state != '' ? "<I>(#{h(shelter.state)})</I>" : '')
  end

  def parish_or_region(shelter)
    shelter.parish != '' ? parish_link(shelter) : (shelter.region != '' ? "<I>(#{h(shelter.region)})</I>" : (shelter.state != '' ? "<I>(#{h(shelter.state)})</I>": ''))
  end

  def town_or_parish(shelter)
    shelter.town != '' ? h(shelter.town) : (shelter.parish != '' ? "<I>(#{h(shelter.parish)} County)</I>" : (shelter.region != '' ? "<I>(#{h(shelter.region)})</I>" : (shelter.state != '' ? "<I>(#{h(shelter.state)})</I>" : '')))
  end

  def region_link(shelter)
#    if shelter.state != ''
#      link_to h(shelter.region), :state => shelter.state, :region => shelter.region
#    else
      h(shelter.region)
#    end
  end

  def parish_link(shelter)
#    if shelter.state != ''
#      link_to h(shelter.parish), :state => shelter.state, :parish => shelter.parish
#    else
      h(shelter.parish)
#    end
  end

  def state_link(shelter)
    h(shelter.state)
  end
  
  def fee_required(shelter)
    case shelter.is_fee_required    
    when 'Yes'
      out = 'Yes - ' + number_to_currency(shelter.fee_amount)
      out << " - Fee Includes #{shelter.fee_is_for}" if shelter.fee_is_for      
    when 'N/A'
      out = nil
    else
      out = shelter.is_fee_required
    end
  end
  
  def temp_perm_service(shelter)
    return if shelter.temp_perm.nil?
    out = shelter.temp_perm
    if shelter.temp_perm == 'Temporary' and not shelter.planned_enddate.blank?
      out << ' - Ending ' + shelter.planned_enddate.to_s
    end
    out
  end

end
