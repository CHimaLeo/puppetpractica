# @summary
#   Installs and configures `mod_ldap`.
# 
# @param package_name
#   Specifies the custom package name.
# 
# @param ldap_trusted_global_cert_file
#   Sets the file or database containing global trusted Certificate Authority or global client certificates.
# 
# @param ldap_trusted_global_cert_type
#   Sets the certificate parameter of the global trusted Certificate Authority or global client certificates.
# 
# @param ldap_shared_cache_size
#   Size in bytes of the shared-memory cache
# 
# @param ldap_cache_entries
#   Maximum number of entries in the primary LDAP cache
# 
# @param ldap_cache_ttl
#   Time that cached items remain valid (in seconds).
# 
# @param ldap_opcache_entries
#   Number of entries used to cache LDAP compare operations
# 
# @param ldap_opcache_ttl
#   Time that entries in the operation cache remain valid (in seconds).
# 
# @param ldap_trusted_mode
#   Specifies the SSL/TLS mode to be used when connecting to an LDAP server.
#
# @param ldap_path
#   The server location of the ldap status page.
#
# @example 
#   class { 'apache::mod::ldap':
#     ldap_trusted_global_cert_file => '/etc/pki/tls/certs/ldap-trust.crt',
#     ldap_trusted_global_cert_type => 'CA_DER',
#     ldap_trusted_mode             => 'TLS',
#     ldap_shared_cache_size        => 500000,
#     ldap_cache_entries            => 1024,
#     ldap_cache_ttl                => 600,
#     ldap_opcache_entries          => 1024,
#     ldap_opcache_ttl              => 600,
#   }
#
# @see https://httpd.apache.org/docs/current/mod/mod_ldap.html for additional documentation.
# @note Unsupported platforms: CentOS: 8; RedHat: 8, 9
class apache::mod::ldap (
  Optional[String] $package_name                  = undef,
  Optional[String] $ldap_trusted_global_cert_file = undef,
  String $ldap_trusted_global_cert_type           = 'CA_BASE64',
  Optional[Integer] $ldap_shared_cache_size       = undef,
  Optional[Integer] $ldap_cache_entries           = undef,
  Optional[Integer] $ldap_cache_ttl               = undef,
  Optional[Integer] $ldap_opcache_entries         = undef,
  Optional[Integer] $ldap_opcache_ttl             = undef,
  Optional[String] $ldap_trusted_mode             = undef,
  String $ldap_path                               = '/ldap-status',
) {
  include apache
  ::apache::mod { 'ldap':
    package => $package_name,
  }
  file { 'ldap.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/ldap.conf",
    mode    => $apache::file_mode,
    content => template('apache/mod/ldap.conf.erb'),
    require => Exec["mkdir ${apache::mod_dir}"],
    before  => File[$apache::mod_dir],
    notify  => Class['apache::service'],
  }
}