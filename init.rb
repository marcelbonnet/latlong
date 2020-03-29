require 'redmine'


Redmine::Plugin.register :latlong do
  name 'LatLong Custom Field'
  description 'Geographical information field'
  version '1.0'
  author_url 'https://github.com/marcelbonnet/'
  author 'Marcel Bonnet'

  requires_redmine :version_or_higher => '3.0.0'

end

# dentro de latlong/lib :
require_dependency 'latlong_field_format/formats/latlong_field_format'
require_dependency 'latlong_field_format/patches/custom_field_patch'
require_dependency 'concerns/query_extension'
require_dependency 'issue_extension'

class RedmineLatLongHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_index_bottom, :partial => 'hooks/view_issues_index_bottom'
end
