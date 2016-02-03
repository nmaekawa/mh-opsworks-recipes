# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-elasticsearch

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

stack_name = node[:opsworks][:stack][:name]

elk_attributes = {
  enabled: true,
  es_major_version: '2.x',
  es_version: '2.2.0',
  es_cluster_name: stack_name,
  install_kopf: true
}.merge(node.fetch(:elk, { enabled: false }))

if elk_attributes[:enabled] 

  es_major_version = elk_attributes[:es_major_version]
  es_version = elk_attributes[:es_version]
  es_cluster_name = elk_attributes[:es_cluster_name]

  apt_repository 'elasticsearch' do
    uri "http://packages.elasticsearch.org/elasticsearch/#{es_major_version}/debian"
    components ['stable', 'main']
    keyserver 'ha.pool.sks-keyservers.net'
    key '46095ACC8548582C1A2699A9D27D666CD88E42B4'
  end

  include_recipe "mh-opsworks-recipes::update-package-repo"
  install_package("elasticsearch=#{es_version}")

  service "elasticsearch" do
    supports :restart => true, :start => true, :stop => true
    action :nothing
  end

  if elk_attributes[:install_kopf]
    execute "install kopf plugin" do
      not_if { ::Dir.exist?("/usr/share/elasticsearch/plugins/kopf") }
      command '/usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0'
      timeout 30
      retries 5
      retry_delay 15
    end
  end

  template '/etc/elasticsearch/elasticsearch.yml' do
    source 'elasticsearch.yml.erb'
    variables({
      cluster_name: es_cluster_name
    })
    notifies :restart, "service[elasticsearch]"
  end
end
