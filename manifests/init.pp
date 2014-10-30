# NTP Service Definition
#  Allows overriding variables on a per-host basis.
define ntp ($servers,
            $restrict=[],
            $keysfile='/etc/ntp/keys',
            $driftfile='/var/lib/ntp/drift',
            $preferred_servers=[]) {

    package { 'ntp' :
        ensure => $::is_virtual ? {
            'true'   => absent,
            default  => latest
        }
    }

    case $::is_virtual {
        'false': {
            service { 'ntpd' :
                name      => $::osfamily ? {
                    RedHat  => 'ntpd',
                    default => 'ntp',
                },
                ensure    => running,
                enable    => true,
                require   => Package['ntp'],
                subscribe => File['ntp.conf'],
            }

            file { 'ntp.conf' :
                ensure  => present,
                mode    => '0644',
                owner   => 'root',
                group   => 'root',
                require => Package['ntp'],
                path    => '/etc/ntp.conf',
                content => template('puppet_header.tpl', 'ntp/ntp.conf.erb'),
            }

            file { 'ntp_keysdir':
                ensure  => directory,
                mode    => '0755',
                owner   => 'root',
                group   => 'root',
                require => Package['ntp'],
                path    => inline_template('<%= File.dirname(@keysfile) %>'),
            }
            file { 'ntp_keysfile':
                ensure  => present,
                mode    => '0600',
                owner   => 'root',
                group   => 'root',
                require => [ Package['ntp'], File['ntp_keysdir'] ],
                path    => $keysfile,
            }

            file { 'ntp_driftdir':
                ensure  => directory,
                mode    => '0755',
                owner   => 'ntp',
                group   => 'ntp',
                require => Package['ntp'],
                path    => inline_template('<%= File.dirname(@driftfile) %>'),
            }
            file { 'ntp_driftfile':
                ensure  => present,
                mode    => '0644',
                owner   => 'ntp',
                group   => 'ntp',
                require => [ Package['ntp'], File['ntp_driftdir'] ],
                path    => $driftfile,
            }
        }
    }
}
