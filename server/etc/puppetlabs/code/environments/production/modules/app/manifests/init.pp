class app(
  $version     = 'latest',
  $db_host     = 'localhost',
  $db_name     = 'wordpress',
  $db_user     = 'wordpressuser',
  $db_password = 'password',
){

# Instalación de paquetes necesarios
  package { ['nginx', 'apache2', 'mysql-server', 'php', 'php-mysql']:
    ensure => installed,
  }

# Inicio de paquetes
  service { 'nginx':
    ensure => 'running',
    enable => true,
    require => Package['nginx'],
  }

  service { 'apache2':
    ensure  => 'running',
    enable  => true,
    require => Package['apache2'],
  }

  service { 'mysql-server':
   ensure => running,
   enable => true,
   require => Package['mysql-server'],
  }

 #Configuración de Apache
  file { '/etc/apache2/sites-available/wordpress.conf':
    ensure  => present,
    content => template('app/wordpress_apache.conf.erb'),
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/sites-enabled/wordpress.conf':
    ensure  => link,
    target  => '/etc/apache2/sites-available/wordpress.conf',
    notify  => Service['apache2'],
  }

# Creación de base de datos y usuario de MySQL
#  exec { 'create_database':
#    command => "mysql -u root -e 'CREATE DATABASE IF NOT EXISTS ${db_name};'",
#    unless  => "mysql -u root -e 'SHOW DATABASES LIKE \"${db_name}\";'",
#    require => Package['mysql-server'],
#  }

#  exec { 'create_user':
#    command => "mysql -u root -e 'CREATE USER IF NOT EXISTS ${db_user}@${db_host} IDENTIFIED BY \"${db_password}\";'",
#    unless  => "mysql -u root -e 'SELECT user FROM mysql.user WHERE user = \"${db_user}\" AND host = \"${db_host}\";' | grep ${db_user}",
#    require => Package['mysql-server'],
#  }

#  exec { 'grant_privileges':
#    command => "mysql -u root -e 'GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${db_host} WITH GRANT OPTION;'",
#    unless  => "mysql -u root -e 'SHOW GRANTS FOR ${db_user}@${db_host};' | grep ${db_name}",
#    require => Package['mysql-server'],
#  }

# Descarga e instalación de WordPress
  exec { 'download-wordpress':
    command => 'wget https://wordpress.org/latest.tar.gz -P /tmp/',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    creates => '/tmp/latest.tar.gz',
  }

  exec { 'extract-wordpress':
    command     => 'tar -xzf /tmp/latest.tar.gz -C /var/www/html/',
    path        => ['/usr/bin', '/usr/sbin', '/bin'],
    creates     => '/var/www/html/wordpress',
    require     => Exec['download-wordpress'],
    before      => Exec['configure-wordpress'],
    refreshonly => true,
  }

  exec { 'configure-wordpress':
    command => 'cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    creates => '/var/www/html/wordpress/wp-config.php',
    require => Exec['extract-wordpress'],
    before  => Exec['set-permissions'],
  }

  exec { 'set-permissions':
    command => 'chown -R www-data:www-data /var/www/html/wordpress',
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    require => Exec['configure-wordpress'],
  }

#
file { '/etc/nginx/sites-available/default':
        ensure => 'file',
        owner => 'root',
        group => 'root',
        mode => '0644',
        content => template('app/nginx.conf.erb'),
        require => Package['nginx'],
        notify => Service['nginx'],
      }

      file { '/etc/nginx/sites-enabled/default':
        ensure => 'link',
        target => '/etc/nginx/sites-available/default',
        require => File['/etc/nginx/sites-available/default'],
        notify => Service['nginx'],
      }
}
