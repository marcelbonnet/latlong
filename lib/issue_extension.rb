# Usada para salvar uma cópia das coordenadas geográficas na tabela Latlong para viabilizar um filtro otimizado
module IssueExtension
  extend ActiveSupport::Concern

    included do
    	after_save :persistir_coordenadas
    end

    def persistir_coordenadas
    	# Rails.logger.info "="*70
    	# Rails.logger.info "AFTER SAVE ISSUE "
    	# Rails.logger.info self.to_s
    	# Rails.logger.info "="*70
    	# return 
    	# (Issue.find(17826).custom_values.select{|cv| cv.custom_field_id == 352 })[0].value
    	#  (ActiveSupport::JSON.decode (Issue.find(17826).custom_values.select{|cv| cv.custom_field_id == 352 })[0].value.gsub("=>",":"))['latitude']
    	# como saber qual dos custom_value_id eu quero ? posso procurar todos do tipo :latlong, remover todos dessa issue_id da tabela e adicionar de novo
    	campos = []
    	CustomField.all.select{|c| c.field_format == "latlong" }.each{|c| campos.push c.id}
    	
    	minhas_coordendas = Issue.find(self.id).custom_values.select{|cv| campos.include?(cv.custom_field_id) }
    	
    	# remove tudo dessa issue em Latlong e adiciona tudo de novo
		pontos = Latlong.where("issue_id = #{self.id}")
		pontos.delete_all

    	# inserts = []
    	minhas_coordendas.each{|p| 
    		lat = (ActiveSupport::JSON.decode p.value.gsub("=>",":"))['latitude'] 
    		lon = (ActiveSupport::JSON.decode p.value.gsub("=>",":"))['longitude'] 
    		# inserts.push "('POINT(#{lon} #{lat})', #{self.id})"
    		
    		# Atenção: POINT recebe LONG e depois LAT
    		Latlong.create ponto: "POINT(#{lon} #{lat})", issue_id: self.id, issue_custom_field_id: p.custom_field_id
    	}
    	
    	# SQL nativo:
    	# sql = "INSERT into latlongs (ponto, issue_id) VALUES #{inserts.join(", ")}"
    	# ActiveRecord::Base.connection.execute(sql)
    end
end

Issue.send :include, IssueExtension