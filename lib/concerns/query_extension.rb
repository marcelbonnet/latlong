# classe que adiciona funcionalidades em app/models/query.rb (Query class)
module QueryExtension
  extend ActiveSupport::Concern

    included do

		# #######################################################################################################################
		# LEIA OU MORRA!
		# alias_method_chain e suas mágicas (cria três métodos): foo(), foo_with_feature(), and foo_without_feature() 
		# Explicação em http://stackoverflow.com/questions/3695839/ddg#3697391
		# #######################################################################################################################
		# alias para o método de IssueQuery, porque não quero sobrescrevê-lo, mas adicionar coisas novas ao que o método existe faz
		# método IssueQuery::initialize_available_filters é um override de Query::initialize_available_filters 
		# O método initialize_available_filters, declarado em app/models/query.rb (Query class) é invocado por suas subclasses
		# para inicializar um filtro novo
		# sql_for_custom_field : monta query para custom fields
		alias_method_chain :sql_for_custom_field, :latlong
		# monta query para fields do redmine:
		# alias_method_chain :sql_for_field, :latlong

	    
		Query::operators_by_filter_type.merge!({
			:latlong => ["raio"]
		})

		self.operators.merge!({
			    "raio"   => :label_raio
			    })

	
    end

    # Método invocado para montar uma Query para CustomValues de um CustomField
    def sql_for_custom_field_with_latlong(field, operator, value, custom_field_id)
    	# se não usa o operador que declarei para Coordenada Geográfica, então
    	# não é uma query para este custom field de latlong.
    	# Assim, deixemos que o parent resolva a query.
		return sql_for_custom_field_without_latlong(field, operator, value, custom_field_id) if not operator.start_with?("raio")
		
    	sql = ""

	    raioMetros = value[2].to_i * 1000
	    geoQuery = "SELECT issue_id FROM latlongs WHERE issue_custom_field_id=#{custom_field_id} AND ( ST_Distance( ponto, ST_GeographyFromText('SRID=4326;POINT( #{value[1]} #{value[0]} )') ) <= #{raioMetros} )"

	    sql = "issues.id IN ( #{geoQuery} ) " #AND issues.project_id = #{self.project_id}  tem um visibility_by_project_condition no método original
	    Rails.logger.info "custom_field_id ##{custom_field_id}"
	    Rails.logger.info "SQL #{sql}"
	 	sql
	end


  end

Query.send :include, QueryExtension