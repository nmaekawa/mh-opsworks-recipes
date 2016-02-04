# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-kibana

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

stack_name = node[:opsworks][:stack][:name]

elk_attributes = {
  enabled: true,
  kibana_version: '4.4.0',
  kibana_checksum: '82fa06e11942e13bba518655c1d34752ca259bab',
  elasticsearch_host: 'elasticsearch1'
}.merge(node.fetch(:elk, { enabled: false }))

if elk_attributes[:enabled] 

  kibana_version = elk_attributes[:kibana_version]
  kibana_checksum = elk_attributes[:kibana_checksum]
  dl_path = "#{::Chef::Config[:file_cache_path]}/kibana.tar.gz" 
  elasticsearch_host = elk_attributes[:elasticsearch_host]

  group 'kibana' do
    append true
  end

  user 'kibana' do
    supports manage_home: true
    gid 'kibana'
    shell '/bin/false'
    home '/opt/kibana'
  end

  remote_file "/etc/init.d/kibana" do
    source "https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-init"
    mode '0755'
  end
  
  remote_file "/etc/default/kibana" do
    source "https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-default"
  end

  remote_file dl_path do
    source "https://download.elastic.co/kibana/kibana/kibana-#{kibana_version}-linux-x64.tar.gz"
    checksum kibana_checksum
    notifies :run, "bash[install_kibana]", :immediately
  end

  bash "install_kibana" do
    code <<-EOH
      tar -xz --strip-components=1 -C /opt/kibana -f #{dl_path}
      chown -R kibana: /opt/kibana
      update-rc.d kibana defaults 96 9
    EOH
    action :nothing
  end

  service "kibana" do
    supports :restart => true, :start => true, :stop => true
    action :nothing
  end

  template '/opt/kibana/config/kibana.yml' do
    source 'kibana.yml.erb'
    variables({
      elasticsearch_host: elasticsearch_host
    })
    notifies :restart, "service[kibana]"
  end

end
