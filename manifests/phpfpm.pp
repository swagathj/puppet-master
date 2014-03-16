# phpfpm.pp - 2014-02-19 07:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::phpfpm (
  $basedir     = '/srv/www',
  $php_modules = undef,
  $user        = 'nginx',
  $group       = 'nginx'
  ) {

  File {
    owner   => $user,
    group   => $group,
  }
  # ubuntu has seperate ini for php-fpm
  if $::osfamily == 'debian' {
    php::ini { '/etc/php5/fpm/php.ini' :
      display_errors  => 'On',
      short_open_tag  => 'Off',
      date_timezone   => 'America/Denver',
    }
  }
  php::ini { '/etc/php.ini' :
    display_errors  => 'On',
    short_open_tag  => 'Off',
    date_timezone   => 'America/Denver',
  }
  class { 'php::cli' : }
  class { 'php::fpm::daemon' : }
  php::fpm::conf { 'www' :
    listen  => '127.0.0.1:9000',
    user    => $user,
    group   => $group,
    require => Package['nginx'],
  }
  if $php_modules {
    php::module { $php_modules : }
  }
  $php_base_dir = $::osfamily ? {
    'debian'  => '/var/lib/php5',
    'redhat'  => '/var/lib/php',
  }
  file { "${php_base_dir}/session" :
    ensure  => 'directory',
    mode    => '0775',
  }

  if $basedir {
    file { $basedir :
      ensure  => 'directory',
      mode    => '0775',
      require => Package['nginx'],
    }->
    file { "${basedir}/phpinfo.php" :
      ensure  => 'file',
      content => "<?php phpinfo(); ?>\n",
    }
  }
}
