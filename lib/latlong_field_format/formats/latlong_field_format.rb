module Redmine
  module FieldFormat
    class LatlongFormat < Redmine::FieldFormat::Unbounded #cuidado ao escolher a superclasse: o método usado para exibir o dado na tela pode variar? Será que escolhi a classe mais adequada pra LatLong ? Agora já foi ...
      
      # Adiciona latlong como identificador do tipo desta classe. É usado para recuperar valores do atributo CustomField::format_store, por exemplo.
      add "latlong"

      # A partial que contém o formulário HTML para a interface administrativa de Criação/Edição de Campos Personalizados
      self.form_partial = 'latlong/formats/latlong_field_format'

      # Para fins didáticos:
      # Chamado antes de persistir o Campo na interface administrativa. Não se trata do CustomValue do usuário para o CustomField.
      # Quando o administrador criar um novo Campo Personalizado do tipo aqui definido, o método será chamado antes de persistir esse Campo.
      def before_custom_field_save(custom_field)
        # Rails.logger.info "============== BEFORE SAVE ================================"
        # Rails.logger.info "============== custom_field ========" << custom_field.name
        # Rails.logger.info "============== custom_field ========" << custom_field.value   # undefined method `value' for #<IssueCustomField 
      end

      # Converte Coordenadas em DEC para uma String em DMS
      def dec2dms(dec)
        dec  = dec.to_f
        grau = dec.abs.to_i #usar dec.round pode levar a problemas de arredondamento para cima/baixo
        min  = (dec.abs - dec.abs.to_i)*60
        seg  = ((min.abs - min.to_i)*60)
        sinal="+"
        sinal="-" if dec.to_s.match(/^-|[sSoOwW]/)
        "#{sinal}#{grau}º #{min.to_i}\' #{seg.round(1)}\""
      end

      # File 'lib/redmine/field_format.rb'
      # Este método gera o HTML para o formulário de Criação/Edição.
      # 
      # Se houver mais de um Input, o redmine persistirá um CustomValue como representação String de um Hash:
      # Exemplo:
      # valor={"a"=>20, "b"=>"ok"} 
      # será persistido como : valor.to_s :
      # "{\"a\"=>20, \"b\"=>\"ok\"}"
      # 
      # Para criar o Hash resultante é preciso que o tag_name e tag_id sejam usados como attributos name e id do Input.
      # Para o Hash resultante ser: {'nome' => <valor informado> , 'sobrenome' => <valor informado> }, os Input devem ser criados como:
      # um Input com ID "#{tag_id}_nome" e outro com ID "#{tag_id}_sobrenome" .
      # Esses Inputs devem ter o atributo NAME como "#{tag_id}[nome]" e "#{tag_id}[sobrenome]", respectivamente.
      #
      # Como o valor é persistido? No momento em que o formulário criado por edit_tag é submetido as variáveis do POST
      # são convertidas em uma String de Hash e persistidas no CustomValue.
      # Parte de um form-data submetido:
      #     Content-Disposition: form-data; name="issue[custom_field_values][352][latitude]"
      #     -15.8448
      #     Content-Disposition: form-data; name="issue[custom_field_values][352][longitude]"
      #     -47.8099
      # Por isso, será persistido pelo Redmine como CustomValue.new(value:"{\"latitude\" => -15.8448, \"longitude\" => -47.8099}", custom_field_id:352)
      def edit_tag(view, tag_id, tag_name, custom_value, options={})
        # custom_field=custom_value.custom_field
        o_custom_value=(JSON::parse(custom_value.value.gsub("=>",":")) rescue {'latitude' => "", 'longitude' => ""})

        # LABEL com os rótulos dos campos
        l_lat = view.label_tag "#{tag_id}_latitude", l(:label_latitude)
        l_lon = view.label_tag "#{tag_id}_longitude", l(:label_longitude)
        
        # INPUT para latitude e longitude
        f_lat = view.text_field_tag("#{tag_name}[latitude]", o_custom_value['latitude'], options.merge(:id => "#{tag_id}_latitude", "onchange" => "#{tag_id}(event,1)", "title" => "Informe latitude decimal ou Grau Minuto Segundo", "placeholder" => "Decimal ou Grau Min Seg"))
        f_lon = view.text_field_tag("#{tag_name}[longitude]", o_custom_value['longitude'], options.merge(:id => "#{tag_id}_longitude", "onchange" => "#{tag_id}(event,2)", "title" => "Informe latitude decimal ou Grau Minuto Segundo", "placeholder" => "Decimal ou Grau Min Seg"))

        # converte de DEC para DMS:        
        dms_lat = dec2dms(o_custom_value['latitude']) if not o_custom_value['latitude'].empty?
        dms_lon = dec2dms(o_custom_value['longitude']) if not o_custom_value['longitude'].empty?
        # SPAN para imprimir as coordenadas em DMS
        s_lat = view.content_tag(:span,dms_lat, {"id" => "#{tag_id}_latitude_dms" , "style" => "font-size: 90%" } )
        s_lon = view.content_tag(:span,dms_lon, {"id" => "#{tag_id}_longitude_dms", "style" => "font-size: 90%" } )

        # DIV para os INPUTs
        div_lat = view.content_tag(:p, l_lat + f_lat + s_lat )
        div_lon = view.content_tag(:p, l_lon + f_lon + s_lon )

        # #{tag_id} é um nome único, então usarei como nome da função javascript
        # O CustomField tem um validator para aceitar apenas Coordenadas em Decimal.
        # Para converter o valor de DMS para Decimal no server side exigiria um patch no Controller de Issues, identificando apenas a Request de lat_lon dentre todas as Requestes do Controller. 
        # Exige menos esforço deixar a facilidade para o usuário em JS. O impacto na regra de negócio é nulo.
        # Se fosse server side, ruby code:
        #   str_coord = value.tr('^[0-9]',' ')
        #   dec_coord = str_coord.split[0].to_i + str_coord.split[1].to_f/60 + str_coord.split[2].to_f/3600
        js=<<-EOS
        /*
          Converte de Decimal para DMS
          @var s Coordenadas em decimal
        */
        function dec2dms_#{tag_id}(s){
            var dec   = parseFloat(s)
            var grau  = parseInt(Math.abs(dec))
            var min   = (Math.abs(dec) - parseInt(Math.abs(dec)))*60
            var seg   = (Math.abs(min) - parseInt(min))*60
            
            sinal="+"
            if( dec.toString().match(/^-|[sSoOwW]/) )
              sinal="-"
            
            var dms = sinal + grau +"º " + parseInt(min) + "\' " + seg.toFixed(1) + '\"'
            
            return dms
        }

        /*
          Facilidade para o usuário: permite a entrada de coordenadas em DEC/DMS mas converte para DEC (padrão no servidor)
          @var event Evento que disparou a chamada da função (ex.: onblur)
          @var i Informar 1 para Latitude e 2 para Longitude
        */
        function #{tag_id}(event, i){
          var s = $(event.target).val()
          // obtém as coordenadas, independente de formato digitado pelo usuário
          var arr = $(event.target).val().replace(/[^0-9]/g," ").trim().split(" ");
          var coord = $.grep(arr, function(item){ return $.isNumeric(item)} )
          var dms = ""  //Coordenadas na forma "Degree Minute Second"
          var dec = 0  //Coordenadas em formato Decimal

          //se tivermos grau, minuto e segundo detectados, podemos converter para decimal
          if ( coord.length == 3 ) {
            var sinal = 1;
            if (s.match(/^-/) || s.match(/[sSoOwW]/) ) sinal = -1
            dec = (sinal * (parseInt(coord[0]) + parseInt(coord[1])/60. + parseInt(coord[2])/3600.)).toFixed(6)
            dms = dec2dms_#{tag_id}(dec)

            // Converte o valor digitado em DMS para DEC
            $(event.target).val(dec)
          } else
            dec = parseFloat(s)
          
          dms = dec2dms_#{tag_id}(dec)

          // Informa o usuário do valor em DMS, para evitar confusões:
          if(i == 1)
            $("##{tag_id}_latitude_dms").html(dms)
          if(i == 2)
            $("##{tag_id}_longitude_dms").html(dms)
        }
        EOS

        # javascript:
        script=view.javascript_tag(js)
        # HTML final:
        div_lat + div_lon + script
      end

      # O redmine chama para exibir o dado do plugin na tela, como modo leitura.
      # Define como o valor armazenado (um JSON ou um valor simples) será formatado na Apresentação.
      def cast_single_value(custom_field, value, customized=nil)
        o_custom_value=(JSON::parse(value.gsub("=>",":")) rescue {})#.values
        str = ""
        # if not value.empty? and o_custom_value.has_key?('latitude')
        #   str = "Latitude: " << o_custom_value['latitude'] << " (#{dec2dms(o_custom_value['latitude'])})" << " Longitude: "  << o_custom_value['longitude'] << " (#{dec2dms(o_custom_value['longitude'])})" 
        # end
        # str
        return "" if value.empty? or !o_custom_value.has_key?('latitude')
        
        lat = o_custom_value['latitude']
        lon = o_custom_value['longitude']

        return "" if lat.to_i == 0 or lon.to_i == 0

        str = "<p>Latitude: " << o_custom_value['latitude'] << " (#{dec2dms(o_custom_value['latitude'])}) </p>"
        str << "<p>Longitude: " << o_custom_value['longitude'] << " (#{dec2dms(o_custom_value['longitude'])}) </p>"

        # Gambiarra para impressionar usuários até que o servidor Open Street Maps esteja instalado no servidor do Fiscaliza

        r = srand

        js = <<-EOS
          <script>
          $(document).ready(function(){
            var map = L.map("osm-map#{r}").setView([#{lat},#{lon}],14);
            //L.tileLayer('http://rosm:8080/osm_tiles/{z}/{x}/{y}.png',{maxZoom:18}).addTo(map);
            L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{maxZoom:18}).addTo(map);

            // Target's GPS coordinates.
            var target = L.latLng('#{lat}','#{lon}');

            // Set map's center to target with zoom 14.
            map.setView(target, 14);

            // Place a marker on the same location.
            L.marker(target).addTo(map);
          });
          </script>
        EOS
        js << "<script src=\"https://unpkg.com/leaflet@1.6.0/dist/leaflet.js\"></script>"
        css = "<link href=\"https://unpkg.com/leaflet@1.6.0/dist/leaflet.css\" rel=\"stylesheet\"/>"
        div = "<div id=\"osm-map#{r}\" style=\"width:200px;height:200px\"></div>"
        # h="<p><strong>" + str + "<strong/><p/><p><img src=\"http://rosm:8080/osm_tiles/10/368/587.png\">"
        h = js + css + div + str
        h.html_safe
      end

      

      # File 'lib/redmine/field_format.rb'
      # Realiza a validação de cada custom_value (chamado por 'validate_custom_value(custom_value)')
      def validate_single_value(custom_field, value, customized=nil)
        # Recupera o objeto JSON de valores do banco de dados
        o_custom_value=(JSON::parse(value.gsub("=>",":")) rescue {})
        # array de mensagens
        errs=[]

        # ################## 
        # Validações
        # ##################
        errs << "#{l('label_latitude')} #{l('activerecord.errors.messages.empty')}" if o_custom_value['latitude'].blank? && custom_field.is_required?
        errs << "#{l('label_longitude')} #{l('activerecord.errors.messages.empty')}" if o_custom_value['longitude'].blank? && custom_field.is_required?

        errs << "#{l('label_latitude')}=#{o_custom_value['latitude']} #{l('activerecord.errors.messages.invalid')}" unless o_custom_value['latitude'].blank? or o_custom_value['latitude']=~Regexp.new(custom_field.format_store['latlong']['lat_validator_regex']) 
        errs << "#{l('label_longitude')}=#{o_custom_value['longitude']} #{l('activerecord.errors.messages.invalid')}" unless o_custom_value['longitude'].blank? or o_custom_value['longitude']=~Regexp.new(custom_field.format_store['latlong']['long_validator_regex']) 
        
        
        # retorna o array com as mensagens resultantes da validação
        errs
      end

      # Esse método é chamado quando a o Redmine monta os Filtros na página de listagem de Issues.
      # Ele adiciona um campo de filtro para esse CustomField . O campo possui opções de filtragem baseada no JSON retornado
      # @var query : IssueQuery
      # @return um JSON com o tipo de filtro que será construído para esse custom field
      def query_filter_options(custom_field, query)
        # Rails.logger.info "="*70
        # Rails.logger.info "==> query_filter_options"
        # Rails.logger.info "Custom Field " << custom_field.name << " ID " << custom_field.id.to_s
        # query.attributes.each{|a| Rails.logger.info a}
        # Rails.logger.info @query.to_s
        # Rails.logger.info "="*70
        {:type => :latlong}
      end

   end
  end
end
