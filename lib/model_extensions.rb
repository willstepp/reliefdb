module ModelExtensions
  def access(attr, user)
    if sensitive_access?(attr)
      send(attr, user)
    else
      send(attr)
    end
  end

  def sensitive_access?(attr)
    return [:updated_by, :updatedbyid].include?(attr.to_sym)
  end

  def updated_by(user)
    sensitive_access("updated_by", user)
  end

  def updated_by_id(user)
    sensitive_access("updatedbyid", user)
  end

  def sensitive_access(attr, user, bypass=false)
    val = read_attribute(attr)
    if bypass
      return val
    end
    if val.nil? or val == ""
      ""
    else
      if user and user.priv_read_sensitive
        return val
      elsif respond_to?('trust_user?') and trust_user?(user)
        return val
      else
        return "(hidden)"
      end
    end
  end

  ### Before_save filters
  def check_updated_by
    if not @updated_updated_by
      return false
    else
      return true
    end
  end

  class HistorySaveError
  end
  def update_history
    check_updated_by and History.of(self).save or raise "Could not save history."
  end
  ###
 
  def history
    History.find(:all, :conditions => ["histories.objtype = ? AND histories.objid = ?", self.class.to_s, self.id], :order => 'timestamp DESC', :include => :updated_by)
  end

  def set_updated_by(user)
    if user
      self.updated_by = user
      @updated_updated_by = true
    end
  end

  def safe_upd_by()
    who = updated_by
    if who
      who.initials
    end
  end

  def sanitize_sql(str)
    ActiveRecord::Base.public_sanitize_sql(str)
  end

end

class ActiveRecord::Base
  include ModelExtensions

  def self.public_sanitize_sql(str)
    #sanitize_sql(str)
    puts "SANITIZING SQL"
    send(:sanitize_sql_array, str)
  end

  # Class methods have to go here
  def self.display_columns
    @display_columns ||= content_columns.reject { |c| c.name == 'lock_version'}
  end
  def self.list_columns
    @list_columns ||= display_columns.reject { |c| c.name =~ /ted_at$/ || c.type == :text || c.type == :float }
  end
end

class LevelSetting
  @levels = {}

  def initialize(val)
    @val = val.to_i
  end

  def to_i
    @val
  end

  def to_s
#    @val.to_s
    name
  end

  def name
    self.class.levels[@val]
  end

  def ==(val)
    val.to_i == @val
  end

  def next
    ary = self.class.levels.keys.sort
    ary[ary.index(to_i) + 1]
  end

  def self.levels
    @levels
  end

  def self.nameof(level)
    @levels[level]
  end
end

class YesNoUnknown < LevelSetting
  @levels = { 0 => "Unknown", 1 => "No", 2 => "Yes" }
end

class ColoredLevelSetting < LevelSetting
  @colors = {}

  def self.colors
    @colors
  end

  def color
    if self.class.colors[to_i]
      return self.class.colors[to_i]
    else
      return '#000000'
    end
  end

  def colored
    s = to_s
    return ('<FONT color="' + color + '">' + s + '</FONT>').html_safe
  end

  def bgcolor
    if self.class.colors[to_i]
      return self.class.colors[to_i]
    else
      return '#FFFFFF'
    end
  end

  def bgcolored
    s = to_s
    return ('<span style="white-space:nowrap;background-color:' + bgcolor + '">' + s + '</span>').html_safe
  end

end

class ExtInteger
  def initialize(val)
    @val = val.to_i
  end

  def method_missing(method, *args)
    @val.send(method, *args)
  end

  def ==(arg)
    @val == arg
  end

  def to_s
    @val.to_s
  end
end

class ErrorAdded < Exception
end
class ErrorAddedOnAttributeAssignment < ErrorAdded
end

