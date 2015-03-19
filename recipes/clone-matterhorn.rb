# Cookbook Name:: mh-opsworks-recipes
# Recipe:: clone-matterhorn

matterhorn_repo_root = node[:matterhorn_repo_root]
git_data = node[:deploy][:matterhorn][:scm]

repo = ''
if git_data.keys.include?(:user)
  # Using a repo in the form of "https://user:pass@repo_url"
  user = git_data[:user]
  password = git_data[:password]
  repo = git_data[:repository]
  fixed_repo = repo.gsub(/\Ahttps?:\/\//,'')
  repo = %Q|https://#{user}:#{password}@#{fixed_repo}|
else
  # Using a repo with an SSH key
  repo = git_data[:repository]
  file '/home/matterhorn/.ssh/id_rsa' do
    owner 'matterhorn'
    group 'matterhorn'
    content git_data[:ssh_key]
    mode '0600'
  end

  file '/home/matterhorn/.ssh/config' do
    owner 'matterhorn'
    group 'matterhorn'
    content %q|
Host *
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  StrictHostKeyChecking no
|
    mode '0600'
  end
end

directory matterhorn_repo_root do
  owner 'matterhorn'
  group 'matterhorn'
  mode '755'
end

git 'Clone matterhorn' do
  repository repo
  revision git_data[:revision]
  destination matterhorn_repo_root
  user 'matterhorn'
  group 'matterhorn'
end
