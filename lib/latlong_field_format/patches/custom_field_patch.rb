module LatlongFieldFormat
  module CustomFieldPatch
    extend ActiveSupport::Concern
    
    # Define o JSON (atributos personalizados) que será inserido no atributo format_store do CustomField
    def latlong=(arg)
      format_store["latlong"]={}
      format_store["latlong"]["lat_validator_regex"]=arg.fetch("lat_validator_regex","")
      format_store["latlong"]["long_validator_regex"]=arg.fetch("long_validator_regex","")
    end
    
    def latlong
      format_store.fetch("latlong",{ "lat_validator_regex" => "", "long_validator_regex" => "" })
    end
    
    def latlong?
      self.field_format=="latlong"
    end
     
  end
end

unless CustomField.included_modules.include?(LatlongFieldFormat::CustomFieldPatch)
  CustomField.send :include, LatlongFieldFormat::CustomFieldPatch
end
