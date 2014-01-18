require 'spec_helper'

describe 'port389::instance', :type => :define do
  let(:facts) {{ :osfamily => 'RedHat' }}

  context 'title =>' do
    context 'ldap1' do
      let(:title) { 'ldap1' }

      it { should contain_port389__instance('ldap1') }
    end

    ['foo/bar', 'foo.bar', 'foo bar'].each do |title|
      context title do
        let(:title) { title }

        it 'should fail' do
        expect { should contain_port389__instance(title) }.
          to raise_error(/It must contain only alphanumeric characters and the following: #%:@_/)
        end
      end
    end
  end

  describe 'setup.inf' do
    before do
      facts[:domain] = 'foo.example.org'
      facts[:fqdn]   = 'bar.foo.example.org'
    end
    let(:title) { 'ldap1' }
    let(:pre_condition) { 'include port389' }

    it do
      should contain_file('setup_ldap1.inf').with({
        :ensure  => 'file',
        :path    => '/var/lib/dirsrv/setup/setup_ldap1.inf',
        :owner   => 'nobody',
        :group   => 'nobody',
        :mode    => '0600',
        :backup  => false,
        :content => <<-EOS
[General]
AdminDomain=foo.example.org
ConfigDirectoryAdminID=admin
ConfigDirectoryAdminPwd=admin
ConfigDirectoryLdapURL=ldap://bar.foo.example.org:389/o=NetscapeRoot
FullMachineName=bar.foo.example.org
ServerRoot=/usr/lib64/dirsrv
SuiteSpotGroup=nobody
SuiteSpotUserID=nobody
[admin]
Port=9830
ServerAdminID=admin
ServerAdminPwd=admin
ServerIpAddress=0.0.0.0
SysUser=nobody
[slapd]
AddOrgEntries=No
AddSampleEntries=No
InstallLdifFile=
RootDN=cn=Directory Manager
RootDNPwd=admin
ServerIdentifier=ldap1
ServerPort=389
SlapdConfigForMC=yes
Suffix=dc=foo,dc=example,dc=org
UseExistingMC=0
ds_bename=userRoot
        EOS
      })
    end

    it do
      should contain_exec('setup-ds-admin.pl_ldap1').with({
        :path      => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
        :command   => 'setup-ds-admin.pl --file=/var/lib/dirsrv/setup/setup_ldap1.inf --silent',
        :unless    => '/usr/bin/test -e /etc/dirsrv/slapd-ldap1',
        :logoutput => true,
      })
    end

    context 'schema_file =>' do
      context '/dne/foo.ldif' do
        let(:params) {{ :schema_file => '/dne/foo.ldif' }}

        it do
          should contain_file('setup_ldap1.inf').with({
            :ensure  => 'file',
            :path    => '/var/lib/dirsrv/setup/setup_ldap1.inf',
            :owner   => 'nobody',
            :group   => 'nobody',
            :mode    => '0600',
            :backup  => false,
            :content => %r{SchemaFile=/dne/foo.ldif},
          })
        end
      end

      context '[ /dne/foo.ldif, /dne/bar.ldif ]' do
        files = %w{ /dne/foo.ldif /dne/bar.ldif }
        let(:params) {{ :schema_file => files }}

        files.each do |f|
          it do
            should contain_file('setup_ldap1.inf').with({
              :ensure  => 'file',
              :path    => '/var/lib/dirsrv/setup/setup_ldap1.inf',
              :owner   => 'nobody',
              :group   => 'nobody',
              :mode    => '0600',
              :backup  => false,
              :content => /SchemaFile=#{files}/
            })
          end
        end
      end

    end # schema_file =>
  end

end
