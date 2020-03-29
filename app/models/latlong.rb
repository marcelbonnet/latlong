 # Esse modelo serve para salvar as coordenadas geográficas numa coluna do tipo Point
 # O objetivo é usar o ganho de performance para calcular distâncias geográficas
 # Na prática haverá duplicidade de valores salvos para todo campo do tipo :latlong :
 # - CustomValue: o valor de coordenadas salvo em String em CustomValue servirá apenas para as necessidades de formulário e auditoria (de alterações) do Redmine.
 # - Latlong: uma tabela separada que persiste as coordenadas em formato geométrico do Postgres
 class Latlong < ActiveRecord::Base
 	belongs_to :issue	# o modelo terá conhecimento da Issue a qual está relacionada a coordenada
 	belongs_to :issue_custom_field	#pode haver muitos campos do tipo latlong e a pesquisa deve se restringir ao campo selecionado pelo usuário
 end