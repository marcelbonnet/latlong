
# #################################################################################################
# MIGRAÇÃO DE LATITUDE/LONGITUDE PARA CAMPO latlong
# Precisava confirmar como desativar o mailer antes de rodar o batch
# #################################################################################################


	# ######################################################################
	# ALTERAR AS IDS PARA QUE CORRESPONDAM AOS VALORES CORRETOS DO SERVIDOR
	# ######################################################################

 # Criar os dois custom field via script, pegar as IDs e usar para receber os valores de coordenadas dos campos atuais
 # Informar o Lanzoni dessas mudanças para que ele atualize nos Relatórios do Qlik Sense
 
 # procurar os que tem algum dado de Latitude:
 CUSTOM_FIELD_ID=352	#ID do meu Novo CustomField que receberá a transferência de values a partir de um CustomValue de CustomField obsoleto

 CustomField.where({ id: [170,191]}).each{ |cf|
 	cf.custom_values.each{|cv| 
 		issue = Issue.find(cv.customized_id)
 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 170 || cv.custom_field.id == 171) } if cf.id == 170
 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 191 || cv.custom_field.id == 192) } if cf.id == 191
 		if !values.nil? && !values[0].value.nil? && !values[0].value.empty? 
 			lat = (values.find{|o| o.custom_field_id == 170 })
 			lon = (values.find{|o| o.custom_field_id == 171 })
 			lat = lat.value if not lat.nil?
 			lon = lon.value if not lon.nil?
 			novoValue = { 
	 			"latitude" => lat ,
	 			"longitude" => lon
	 		}
	 		
	 		# puts "Issue ##{issue.id}	#{lon}/#{lat} ==> #{novoValue}" 
 		end
 	}
 };nil

# ########################## TS ################################
# redmine_fiscaliza_ts_1=# SELECT COUNT(*) FROM custom_values WHERE custom_field_id IN (170,171) AND value != '';
#  count 
# -------
#   4142
# (1 row)

# redmine_fiscaliza_ts_1=# SELECT COUNT(*) FROM custom_values WHERE custom_field_id IN (191,192) AND value != '';                                                                               
#  count 
# -------
#    202
# (1 row)

# redmine_fiscaliza_ts_1=# SELECT id, name FROM custom_fields WHERE id IN (170,171,191,192);
#  id  |          name           
# -----+-------------------------
#  170 | Latitude (coordenadas)
#  191 | Latitude da estação
#  192 | Longitude da estação
#  171 | Longitude (coordenadas)
# (4 rows)

 CustomField.where({ id: [191]}).each{ |cf|
 	cf.custom_values.each{|cv| 
 		issue = Issue.find(cv.customized_id)
 		# values = issue.custom_values.select{|cv| (cv.custom_field.id == 170 || cv.custom_field.id == 171) } if cf.id == 170
 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 191 || cv.custom_field.id == 192) } if cf.id == 191
 		if !values.nil? && !values[0].value.nil? && !values[0].value.empty? 
 			lat = (values.find{|o| o.custom_field_id == 170 })
 			lon = (values.find{|o| o.custom_field_id == 171 })
 			lat = lat.value if not lat.nil?
 			lon = lon.value if not lon.nil?
 			novoValue = { 
	 			"latitude" => lat ,
	 			"longitude" => lon
	 		}
	 		
	 		# puts "Issue ##{issue.id}	#{lon}/#{lat} ==> #{novoValue}" 
 		end
 	}
 };nil



# copiando do 352 para o Latlongs table:
#Latlong.all.delete_all
CustomField.where({ id: [352]}).each{ |cf|
 	cf.custom_values.each{|cv| 
 		issue = Issue.find(cv.customized_id)
 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 352) }

 		if !values.nil? && !values[0].value.nil? && !values[0].value.empty? 
 			# lat = (values.find{|o| o.custom_field_id == 170 })
 			# lon = (values.find{|o| o.custom_field_id == 171 })
 			# lat = lat.value if not lat.nil?
 			# lon = lon.value if not lon.nil?
 			# novoValue = { 
	 		# 	"latitude" => lat ,
	 		# 	"longitude" => lon
	 		# }
	 		lat = (ActiveSupport::JSON.decode values[0].value.gsub("=>",":"))['latitude'] 
    		lon = (ActiveSupport::JSON.decode values[0].value.gsub("=>",":"))['longitude'] 
    		o = Latlong.create ponto: "POINT(#{lon} #{lat})", issue_id: issue.id
	 		puts "Issue ##{issue.id}	#{lon}/#{lat} ==> ##{o.id}" 
 		end
 	}
 };nil




	# Criando os CustomFields novos para substituir os numéricos atuais:
	# Não pode repetir o name. Não funcionava porque já tinha um campo com mesmo nome
	# Lembrar de respeitar as constraints: name só pode ser até 30 caracteres
	id1 = 0
	id2 = 0
	name="Coordenadas Geográficas"	#length <= 30
	name << "Novo" if IssueCustomField.where("name = '#{name}'").size > 0
	cf = IssueCustomField.create name: name, field_format: "latlong", is_for_all: true, is_filter: true, description: "Coordenadas geográficas", format_store:  {"assignment"=>false, "watcher"=>false, "conditions"=>{}, "latlong"=>{"lat_validator_regex"=>"(^([-]?[0-9]{1,2})$)|(^([-]?[0-9]{1,2}.[0-9]{1,15})$)", "long_validator_regex"=>"(^([-]?[0-9]{1,2})$)|(^([-]?[0-9]{1,2}.[0-9]{1,15})$)"}}
	trackers = IssueCustomField.find(170).trackers
	cf.trackers = trackers
	id1 = cf.id

	name="Coordenadas Geog. Estação"	#length <= 30
	name << "Novo" if IssueCustomField.where("name = '#{name}'").size > 0
	cf=nil
	cf = IssueCustomField.create name: name, field_format: "latlong", is_for_all: true, is_filter: true, description: "Coordenadas geográficas", format_store:  {"assignment"=>false, "watcher"=>false, "conditions"=>{}, "latlong"=>{"lat_validator_regex"=>"(^([-]?[0-9]{1,2})$)|(^([-]?[0-9]{1,2}.[0-9]{1,15})$)", "long_validator_regex"=>"(^([-]?[0-9]{1,2})$)|(^([-]?[0-9]{1,2}.[0-9]{1,15})$)"}}
	trackers = IssueCustomField.find(191).trackers
	cf.trackers = trackers
	id2 = cf.id

	CustomField.where({ id: [170,191]}).each{ |cf|
	 	cf.custom_values.each{|cv| 
	 		issue = Issue.find(cv.customized_id)
	 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 170 || cv.custom_field.id == 171) } if cf.id == 170
	 		values = issue.custom_values.select{|cv| (cv.custom_field.id == 191 || cv.custom_field.id == 192) } if cf.id == 191
	 		if !values.nil? && !values[0].value.nil? && !values[0].value.empty? 
	 			lat = (values.find{|o| o.custom_field_id == 170 ||  o.custom_field_id == 191 })
	 			lon = (values.find{|o| o.custom_field_id == 171 ||  o.custom_field_id == 192 })
	 			lat = lat.value if not lat.nil?
	 			lon = lon.value if not lon.nil?
	 			novoValue = { 
		 			"latitude" => lat ,
		 			"longitude" => lon
		 		}

		 		cfid = nil
		 		cfid = id1 if cf.id == 170
		 		cfid = id2 if cf.id == 191

		 		# Cria o registro que será usado para pesquisa geográfica (artifício técnico para otimização da pesquisa)
	    		Latlong.create ponto: "POINT(#{lon} #{lat})", issue_id: issue.id, issue_custom_field_id: cfid

		 		# Cria o Custom Value para manter o valor para fins Administrativos
		 		ncv = CustomValue.create( customized_type: "Issue", customized_id: issue.id, custom_field_id: cfid, value: novoValue)
		 		# Cria Auditoria
				journal=Journal.create(journalized_id: issue.id , journalized_type: "Issue", user_id: 1, notes: "Atualiza&ccedil;&atilde;o em Batch pelo Grupo de Trabalho do Fiscaliza: movendo valores dos campos Latitude/Longitude para o novo campo Coordenadas Geogr&aacute;ficas para oferecer mais recursos ao usu&aacute;rio do Fiscaliza.")
				JournalDetail.create( journal_id: journal.id, property: "cf", prop_key: "#{cfid}", old_value: "", value: novoValue )
				# Remove os CustomValue dos campos obsoletos
		 		# values[0].delete
		 		# values[1].delete
	 		end
	 	}
	 }; nil
	 # Remove os campos obsoletos
	 CustomField.where({ id: [170,171,191,192]}).delete_all
