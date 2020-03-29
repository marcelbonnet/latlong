class CreateLatlong < ActiveRecord::Migration
  def change
  	enable_extension :postgis
  	# Como usar o Adaptador Postgis:
  	# https://github.com/rgeo/activerecord-postgis-adapter
    create_table :latlongs do |t|
      # t.column :ponto, :geometry
      t.st_point :ponto, geographic: true
      t.index :ponto, using: :gist
    end
    # adiciona a fk issue sem integridade referencial
    add_column :latlongs, :issue_id, :int, :default => nil
    add_column :latlongs, :issue_custom_field_id, :int, :default => nil
  end
end