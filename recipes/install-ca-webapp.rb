# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-ca-webapp

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

ca_webapp_info = node.fetch(:ca_webapp, {})

git "get cadash python webapp" do
  repository ca_webapp_info.fetch(:webapp_git_repo, 'https://github.com/harvard-dce/webapp')
  revision ca_webapp_info.fetch(:webapp_git_revision, 'master')
  destination '/home/web/sites/cadash'
  user 'web'
end

file '/home/web/sites/cadash/cadash.env' do
  owner 'web'
  group 'web'
  content %Q|
export CA_STATS_USER="#{ca_webapp_info[:ca_stats_user]}"
export CA_STATS_PASSWD="#{ca_webapp_info[:ca_stats_passwd]}"
export CA_STATS_JSON_URL="#{ca_webapp_info[:ca_stats_json_url]}"
export EPIPEARL_USER="#{ca_webapp_info[:epipearl_user]}"
export EPIPEARL_PASSWD="#{ca_webapp_info[:epipearl_passwd]}"
export LDAP_HOST="#{ca_webapp_info[:ldap_host]}"
export LDAP_BASE_SEARCH="#{ca_webapp_info[:ldap_base_search]}"
export LDAP_BIND_DN="#{ca_webapp_info[:ldap_bind_dn]}"
export LDAP_BIND_PASSWD="#{ca_webapp_info[:ldap_bind_passwd]}"
export LOG_CONFIG="#{ca_webapp_info[:log_config]}"
export CADASH_SECRET="#{ca_webapp_info[:cadash_secret]}"
|
  mode '600'
end

execute 'create virtualenv' do
  code '/usr/bin/virtualenv /home/web/sites/cadash/venv'
  user 'web'
end

#execute %Q|sudo -H -u web virtualenv /home/web/sites/cadash/venv|

#execute %Q|sudo -H -u web /home/web/sites/cadash/venv/bin/pip install -r /home/web/sites/cadash/requirements.txt|

execute 'install webapp dependencies' do
  code 'source /home/web/sites/cadash/venv/bin/activate && pip install -r /home/web/sites/cadash/requirements.txt'
  user 'web'
end

