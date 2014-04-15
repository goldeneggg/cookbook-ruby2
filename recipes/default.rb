#
# Cookbook Name:: ruby2
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node[:ruby2][:dependency_packages].each do |pkg|
    package pkg do
        action :install
    end
end

directory "#{node[:ruby2][:root_src_work]}" do
    owner "root"
    action :create
    not_if "ls #{node[:ruby2][:root_src_work]}"
end

script "ruby2" do
    interpreter "bash"
    user "root"
    cwd "#{node[:ruby2][:root_src_work]}"
    code <<-EOH
        wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-#{node[:ruby2][:version]}.tar.gz
        tar -zxvf ruby-#{node[:ruby2][:version]}.tar.gz
        cd ruby-#{node[:ruby2][:version]}
        ./configure --prefix=#{node[:ruby2][:prefix]}
        make
        make install
    EOH
    not_if "ls #{node[:ruby2][:prefix]}/bin/ruby"
end

node[:ruby2][:gem_base_packages].each do |pkg|
    execute "gem_install_#{pkg}" do
        user "root"
        command "#{node[:ruby2][:prefix]}/bin/gem install #{pkg}"
        only_if "ls #{node[:ruby2][:prefix]}/bin/gem"
        not_if "#{node[:ruby2][:prefix]}/bin/gem list -l | grep #{pkg}"
    end
end

node[:ruby2][:gem_additional_packages].each do |pkg|
    execute "gem_install_#{pkg}" do
        user "root"
        command "#{node[:ruby2][:prefix]}/bin/gem install #{pkg}"
        only_if "ls #{node[:ruby2][:prefix]}/bin/gem"
        not_if "#{node[:ruby2][:prefix]}/bin/gem list -l | grep #{pkg}"
    end
end
