# Cookbook Name:: mh-opsworks-recipes
# Recipe:: configure-ca-webapp-supervisor

include_recipe "mh-opsworks-recipes::update-package-repo"
::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
install_package('supervisor')

template %Q|/etc/supervisor/conf.d/cadash.conf| do
  source 'ca-webapp-supervisor-conf.erb'
  variables({
    ca_webapp: 'cadash'
  })
end

command %Q|supervisorctl reread && supervisorctl update && supervisorctl start cadash|
