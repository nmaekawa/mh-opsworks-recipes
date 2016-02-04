# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-logstash

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

stack_name = node[:opsworks][:stack][:name]

elk_attributes = {
  tcp_port: '5000',
  logstash_major_version: '2.1',
  logstash_version: '1:2.1.1-1',
  stdout_output: true,
  elasticsearch_host: 'elasticsearch1',
  elasticsearch_index_prefix: "dce-#{stack_name}"
}.merge(node.fetch(:elk, {))

if !elk_attributes.empty?

  logstash_major_version = elk_attributes[:logstash_major_version]
  logstash_version = elk_attributes[:logstash_version]
  tcp_port = elk_attributes[:tcp_port]
  stdout_output = elk_attributes[:stdout_output]
  elasticsearch_host = elk_attributes[:elasticsearch_host]
  elasticsearch_index_prefix = elk_attributes[:elasticsearch_index_prefix]

  apt_repository 'logstash' do
    uri "http://packages.elasticsearch.org/logstash/#{logstash_major_version}/debian"
    components ['stable', 'main']
    keyserver 'ha.pool.sks-keyservers.net'
    key '46095ACC8548582C1A2699A9D27D666CD88E42B4'
  end

  include_recipe "mh-opsworks-recipes::update-package-repo"
  install_package("logstash=#{logstash_version}")

  service "logstash" do
    supports :restart => true, :start => true, :stop => true
    action :nothing
  end

  template '/etc/logstash/conf.d/logstash.conf' do
    source 'logstash.conf.erb'
    variables({
      tcp_port: tcp_port,
      stdout_output: stdout_output,
      elasticsearch_host: elasticsearch_host,
      elasticsearch_index_prefix: elasticsearch_index_prefix
    })
    notifies :restart, "service[logstash]"
  end
end
