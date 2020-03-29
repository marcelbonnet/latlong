# classe que adiciona funcionalidades em app/models/issue_query.rb (IssueQuery class)
# IssueQuery extend a classe Query para criar filtros específicos para Issue
# Como Coordenada Geográfica é um filtro de Issue, esse é o lugar para adicionar o conhecimento ao Core do Redmine
module IssueQueryExtension
  extend ActiveSupport::Concern

    included do

    	# alias_method :sql_for_custom_field :build_sql
        
		# self.operators.merge!({
		#     "raio>"   => :label_in_more_than,
		#     "raio<"   => :label_in_less_than,
		#     "raio>="   => :label_greater_or_equal,
		#     "raio<="   => :label_less_or_equal,
		#     "raio="   => :label_equals,
		#     })

		# self.operators_by_filter_type.merge({
		# 	:latlong => ["raio>", "raio<", "raio>=", "raio<=", "raio="]
		# })

		# #######################################################################################################################
		# LEIA OU MORRA!
		# alias_method_chain e suas mágicas (cria três métodos): foo(), foo_with_feature(), and foo_without_feature() 
		# Explicação em http://stackoverflow.com/questions/3695839/ddg#3697391
		# #######################################################################################################################
		# alias para o método de IssueQuery, porque não quero sobrescrevê-lo, mas adicionar coisas novas ao que o método existe faz
		# método IssueQuery::initialize_available_filters é um override de Query::initialize_available_filters 
		# O método initialize_available_filters, declarado em app/models/query.rb (Query class) é invocado por suas subclasses
		# para inicializar um filtro novo
		alias_method_chain :initialize_available_filters, :latlong
    end

		# def initialize(attributes=nil, *args)
		# 	Rails.logger.info "="*70
		# 	Rails.logger.info "QUERY TESTE"
		# 	self.operators_by_filter_type.each{|a| puts a}
		# 	operators_by_filter_type.each{|a| puts a}
		# 	Rails.logger.info "="*70
		#     super attributes
		# end



		# Query
		# def sql_for_custom_field(field, operator, value, custom_field_id)
		#     db_table = CustomValue.table_name
		#     db_field = 'value'
		#     filter = @available_filters[field]
		#     return nil unless filter
		#     if filter[:field].format.target_class && filter[:field].format.target_class <= User
		#       if value.delete('me')
		#         value.push User.current.id.to_s
		#       end
		#     end
		#     not_in = nil
		#     if operator == '!'
		#       # Makes ! operator work for custom fields with multiple values
		#       operator = '='
		#       not_in = 'NOT'
		#     end
		#     customized_key = "id"
		#     customized_class = queried_class
		#     if field =~ /^(.+)\.cf_/
		#       assoc = $1
		#       customized_key = "#{assoc}_id"
		#       customized_class = queried_class.reflect_on_association(assoc.to_sym).klass.base_class rescue nil
		#       raise "Unknown #{queried_class.name} association #{assoc}" unless customized_class
		#     end
		#     where = sql_for_field(field, operator, value, db_table, db_field, true)
		#     if operator =~ /[<>]/
		#       where = "(#{where}) AND #{db_table}.#{db_field} <> ''"
		#     end
		#     "#{queried_table_name}.#{customized_key} #{not_in} IN (" +
		#       "SELECT #{customized_class.table_name}.id FROM #{customized_class.table_name}" +
		#       " LEFT OUTER JOIN #{db_table} ON #{db_table}.customized_type='#{customized_class}' AND #{db_table}.customized_id=#{customized_class.table_name}.id AND #{db_table}.custom_field_id=#{custom_field_id}" +
		#       " WHERE (#{where}) AND (#{filter[:field].visibility_by_project_condition}))"
		# end

    def initialize_available_filters_with_latlong
		initialize_available_filters_without_latlong
		Rails.logger.info "*"*70
		Rails.logger.info "FILTRO AQUI"
		Rails.logger.info "*"*70
		# initialize_available_filters
		# # Query::add_available_filter(field,options)
		# add_available_filter("project_id"
	 #        :type => :list, :values => project_values
	 #      )
	end

  end