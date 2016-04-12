# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-memcached

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
install_package('memcached')

ca_webapp_info = node.fetch(:ca_webapp, {memcached_port: '8008'})

execute 'memcached not in default port' do
  command %Q|/usr/bin/sed -i .bak "s/-p 11211/-p #{ca_webapp_info[:memcached_port]}/g" /etc/memcached.conf|
end

execute 'service memcached restart'
