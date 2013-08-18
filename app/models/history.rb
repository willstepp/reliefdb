require 'yaml'


class ::DateTime
	alias_method :to_s, :to_formatted_s
end


class History < ActiveRecord::Base
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"

  serialize :obj

  def self.of(o)
    h = History.new
    h.updated_by = o.updated_by
    h.timestamp = DateTime.now.new_offset
    h.save  # Get an ID for later
    h.objtype = o.class.to_s
    h.objid = o.id
    if o.lock_version == 0 and !History.find_by_objtype_and_objid(h.objtype, h.objid)
      # New object
      h.was_new = true
    end
    if !h.was_new and o.respond_to?('info_source')
      old = o.class.find_by_id(o.id)
      if old and (old.info_source == o.info_source)
        out = ""
      else
        out = tf(o.info_source)
      end
      if h.was_new
	# New object
	out = tf(o.info_source)
      end
      out << '<BR><div id="changes' + h.id.to_s + '" style="display:none">'
      for col in old.class.columns.reject {|c| c.name =~ /ted_at$/ || ['lock_version', 'type', 'info_source', 'updatedbyid'].include?(c.name) }
        if o.sensitive_access?(col.name)
          if o.sensitive_access(col.name, nil, true) != old.sensitive_access(col.name, nil, true)
            out << "<B>#{col.name} changed.</B><BR>"
          end
        else
          if o.send(col.name) != old.send(col.name)
            out << "<B>#{col.name}: </B>#{h(old.send(col.name))} <B>-></B> #{h(o.send(col.name))}<BR>"
          end
        end
      end
      out << '</div>'
      h.update_desc = out
    end
    h.obj = o
    return h
  end

end


module YAML
  def YAML.add_ruby_type(type_tag, &transfer_proc)
    resolver.add_type( "tag:ruby.yaml.org,2002:#{type_tag}", transfer_proc)
  end
end
## Ugly fix off some mailing list for dumping classes to YAML
class Module
   def is_complex_yaml?
     false
   end
   def to_yaml( opts = {} )
     YAML::quick_emit( nil, opts ) { |out|
       out << "!ruby/module "
       self.name.to_yaml( :Emitter => out )
     }
   end
end
YAML.add_ruby_type(/^module/) do |type, val|
   subtype, subclass = YAML.read_type_class(type, Module)
   val.split(/::/).inject(Object) { |p, n| p.const_get(n)}
end

class Class
   def to_yaml( opts = {} )
     YAML::quick_emit( nil, opts ) { |out|
       out << "!ruby/class "
       self.name.to_yaml( :Emitter => out )
     }
   end
end
YAML.add_ruby_type(/^class/) do |type, val|
   subtype, subclass = YAML.read_type_class(type, Class)
   val.split(/::/).inject(Object) { |p, n| p.const_get(n)}
end

