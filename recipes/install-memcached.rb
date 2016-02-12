# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-memcached

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
install_package('memcached')

ca_webapp_info = get_ca_webapp_info

command %Q|/usr/bin/sed -i .bak "s/-p 11211/-p #{ca_webapp_info[:memcached_port]}/g" /etc/memcached.conf|

execute 'service memcached restart'
