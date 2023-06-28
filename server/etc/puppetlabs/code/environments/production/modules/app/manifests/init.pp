class app::wordpress {

# Instalación de paquetes necesarios
  package { ['nginx', 'apache2', 'mysql-server', 'php', 'php-mysql']:
    ensure => installed,
  }
}
