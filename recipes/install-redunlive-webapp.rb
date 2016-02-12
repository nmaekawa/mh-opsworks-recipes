# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-redunlive-webapp

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

ca_app_info = get_ca_app_info

git "get redunlive python webapp" do
  repository "git@bitbucket.org:hudcede/redunlive.git"
  revision master
  destination '/home/web/sites/redunlive'
  user 'web'
end

file '/home/web/sites/redunlive/redunlive.env' do
  owner 'web'
  group 'web'
  content %Q|
export CA_STATS_USER="#{ca_app_info[:ca_stats_user]}"
export CA_STATS_PASSWD="#{ca_app_info[:ca_stats_passwd]}"
export CA_STATS_JSON_URL="#{ca_app_info[:ca_stats_json_url]}"
export REDUNLIVE_ADMIN_PASSWD="#{ca_app_info[:redunlive_admin_passwd]}"
export REDUNLIVE_LOG_LEVEL="#{ca_app_info[:redunlive_log_level]}"
export EPIPEARL_USER="#{ca_app_info[:epipearl_user]}"
export EPIPEARL_PASSWD="#{ca_app_info[:epipearl_passwd]}"
export TESTING="#{ca_app_info[:testing]}"
export FLASK_SECRET_KEY="#{ca_app_info[:flask_secret_key]}"
export DEBUG="#{ca_app_info[:debug]}"
|
  mode '600'
end

bash 'create virtualenv' do
  code 'cd /home/web/sites/redunlive && virtualenv venv'
  user 'web'
end

bash 'install webapp dependencies' do
  code 'cd /home/web/sites/redunlive && source venv/bin/activate && pip install -r requirements.txt'
  user 'web'
end

