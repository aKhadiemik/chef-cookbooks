execute "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E513AA69" do
  not_if "apt-key finger | grep '6E55 0F7A 9E68 40E9 0586  5DAB 343F 33E1 E513 AA69'"
  notifies :run, resources(:execute => "apt-get update"), :immediately
end

template "/etc/apt/sources.list.d/ppa-codebutler.list" do
  source "apt-codebutler.list.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, resources(:execute => "apt-get update"), :immediately
end

package "rubygems"
package "passenger-common"
package "nginx"

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "passenger.conf" do
  path "#{node[:nginx][:dir]}/conf.d/passenger.conf"
  source "passenger.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  service_name 'nginx'
end
