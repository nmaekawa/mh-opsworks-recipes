# Cookbook Name:: mh-opsworks-recipes
# Recipe:: configure-ca-webapp-gunicorn

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)


bash 'install gunicorn' do
  code 'source /home/web/sites/cadash/venv/bin/activate && pip install gunicorn'
  user 'web'
end

template '/home/web/sites/cadash/gunicorn_start.sh' do
  source 'ca-webapp-gunicorn_start.sh.erb'
  owner 'web'
  group 'web'
  mode '775'
end

directory '/home/web/sock' do
  owner 'web'
  group 'web'
  mode '775'
end
