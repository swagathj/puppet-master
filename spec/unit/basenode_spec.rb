# basenode_spec.rb - 2014-03-08 10:00
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

# these are the files for existing repos that the mirror provides.
$repo_files = {
  'Fedora' => ['/etc/yum.repos.d/fedora.repo',
              '/etc/yum.repos.d/fedora-updates.repo',
              '/etc/yum.repos.d/fedora-updates-testing.repo',
              '/etc/yum.repos.d/rpmfusion-free.repo',
              '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
              '/etc/yum.repos.d/rpmfusion-nonfree.repo',
              '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',],
  'CentOS' => ['/etc/yum.repos.d/CentOS-Base.repo',
              '/etc/yum.repos.d/CentOS-Debuginfo.repo',
              '/etc/yum.repos.d/CentOS-Media.repo',
              '/etc/yum.repos.d/CentOS-Vault.repo',
              '/etc/yum.repos.d/epel.repo',
              '/etc/yum.repos.d/pjku.repo',
              '/etc/yum.repos.d/puppetlabs.repo',],
  'Ubuntu' => [''],
}

$common_pkgs = [
  'xterm',
  'emacs',
  'git',
  'subversion',
  'cvs',
  'rcs',
  'automake',
  'sysstat',
  'lsof',
  'nmap',
  'iftop',
  'lynx',
  'zfs-fuse',
  'unar',
  'xorg-x11-apps',
]
   
                
$packages = {
  'Fedora' => $common_pkgs,
  'CentOS' => $common_pkgs,
  'Ubuntu' => $common_pkgs,
}

$mirror='gandalf'
  
['Fedora','CentOS'].each { |os|
  describe 'master::basenode', :type => :class do
    let(:facts) do {
        :osfamily  => 'redhat',
        :operatingsystem => os,
      } end 
    context "supports operating system: #{os}" do
      context "FIXME defaults not supported yet" do
      end
      context "given repo_mirror param" do
        let :params do {
            :repo_mirror => $mirror,
        } end
        context "provides master::basenode class which" do
          it { should contain_class('master::basenode') }

          context "disables existing repos provided by mirror: #{$mirror}" do
            $repo_files[os].each {|rfile|
              it "ensures #{rfile} absent" do 
                should contain_file(rfile).with(
                  'ensure' => 'absent',
                )
              end
            }
          end
          it "installs repo mirror file for yum for #{os}" do
            should contain_file("/etc/yum.repos.d/#{$mirror}.repo").
              with_content(/#{$mirror}/)
          end
        end
      end
      context "param independent features" do
        # FIXME - temp workaround until support of default params
        let :params do {
            :repo_mirror => $mirror,
        } end
        context "installs base packages" do
          $packages[os].each{|pkg|
            it "ensure #{pkg} is installed" do
              should contain_package(pkg).with(
                'ensure' => 'installed',
              )
            end
          }
        end
        it { should contain_service('zfs-fuse').
          with( 'ensure' => 'running',
                'enable' => true, )
        }
        it { should contain_file('/root/scripts/pagent').
          with( 'ensure' => 'file',
                'mode'   => '+x',)
        }
        # this is redhat
        $sudo_grp = 'wheel'
        it { should contain_sudo_conf("group: #{$sudo_grp}") }
        it { should contain_ssh_authorized_key("root-paul") }
        it { should contain_exec('update info dir') }
      end
    end
  end
} # end os loop 
