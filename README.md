# Ativando no Fiscaliza

No menu `Administração > Tipos de Tarefas > Inspeção > Novo`, adicionar campo do tipo Coordenadas Geográficas.

Outras configurações, vide imagens.

# Desenvolvendo com Postgis

* Adaptador Postgis para Ruby, com exemplos: https://github.com/rgeo/activerecord-postgis-adapter
* Postgis SQL https://postgis.net/workshops/postgis-intro/geometries.html

```
SELECT * FROM latlongs WHERE ST_DWithin( ponto,  ST_GeographyFromText('SRID=4326;POINT(-47 -15)'), 100000000);

SELECT ST_Distance( ponto,  ST_GeographyFromText('SRID=4326;POINT(-47 -15)') ) FROM latlongs;
   st_distance   
-----------------
 131978.74726055
(1 row)
```

Menor distância entre Curitiba e Brasília, em metros:
```
SELECT ST_Distance(  ST_GeographyFromText('SRID=4326;POINT(-49.273056 -25.427778)') ,  ST_GeographyFromText('SRID=4326;POINT( -47.929722 -15.779722  )') ) ;                
   st_distance    
------------------
 1077282.96232973
(1 row)

```

## Instalação com Postgis

> A instalação funcionou sem usar a rede da Anatel ?!?!?! Confirmar

### CentOS

repetir o processo. fazer um script. Apenas o necessário para habilitar o postgis.

=> usar o yum e ver se tem postgis , se falta apenas o ruby postgis

```
cd /opt/redmine/
echo "warn('Carregando adaptador postgis para Redmine/Fiscaliza')" > Gemfile.local
echo "gem 'pg', '~> 0.18.1'" >> Gemfile.local
echo "gem 'activerecord-postgis-adapter'" >> Gemfile.local
bundle install --without development test
```

### Ubuntu

Instalar o postgis com `apt-get install postgis`

```
ii  postgis                                   2.2.1+dfsg-2ubuntu0.1     amd64                     Geographic objects support for PostgreSQL
```

Adicionar um arquivo de configuração local para o Redmine (/usr/share/redmine/Gemfile.local), que é importado a partir do script original em /usr/share/redmine/Gemfile, sempre que esse arquivo existir no diretório:
```
# cd /usr/share/redmine
# echo "warn('Carregando adaptador postgis para Redmine/Fiscaliza')" > Gemfile.local 
# echo "gem 'pg', '~> 0.18.1'" >> Gemfile.local 
# echo "gem 'activerecord-postgis-adapter'" >> Gemfile.local 
```

Instalar os headers do Ruby e mandar compilar/instalar o activerecord-postgis-adapter e suas dependências:
```
# apt-get install ruby2.3-dev
# bundle install --without development test
```

Editar o config/database.yml:
```
	#adapter:			postgres
	adapter:            postgis
```

Rodar o script de setup na base de dados existente:
```
# rake db:gis:setup
```

Instalar o plugin latlong e rodar o script de migrate:
```
cd /usr/share/redmine
bin/rake redmine:plugins:migrate NAME=latlong

Unknown database adapter `postgis` found in config/database.yml, use Gemfile.local to load your own database gems                                                                             
Carregando adaptador postgis para Redmine/Fiscaliza
Migrating latlong (LatLong Custom Field)...
== 1 CreateLatlong: migrating =================================================
-- enable_extension(:postgis)
   -> 0.0026s
-- create_table(:latlongs)
   -> 0.0171s
-- add_column(:latlongs, :issue_id, :int, {:default=>nil})
   -> 0.0004s
-- add_column(:latlongs, :issue_custom_field_id, :int, {:default=>nil})
   -> 0.0003s
== 1 CreateLatlong: migrated (0.0207s) ========================================

== 20200310 MigracaoCoordenadas: migrating ====================================
== 20200310 MigracaoCoordenadas: migrated (532.8855s) =========================
```
**Repare que pode demorar uns minutos para migrar as coordenadas dos campos obsoletos para os novos campos.**

## Instalação do Javascript

O arquivo `public/javascript/application.js` é responsável por adicionar os tipos de filtros existentes no *backend* . Contudo, esse javascript não implementa *callbacks* . Logo, é impossível adicionar novos filtros no *frontend* sem alterar o javascript original.

O ideal seria implementar *callbacks* no original e submeter um patch para o Redmine. Mas não tenho tempo nesse momento.

Assim, é preciso renomemar o arquivo `public/javascript/application.js` para `public/javascript/application.js.orig` e copiar o `application.js` local para o Redmine em `public/javascript/` . As modificações não afetam o Redmine negativamente em caso de remoção deste plugin.