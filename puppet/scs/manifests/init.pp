class scs (
    $http_host = 'localhost',

    $plugin_credentials = 'latest',
    $plugin_git = 'latest',
    $plugin_git_client = 'latest',
    $plugin_greenballs = 'latest',
    $plugin_scm_api = 'latest',
    $plugin_subversion = 'latest',
    $plugin_swarm = 'latest',
) {
    file {
        '/usr/bin/scs-runtime-hook-start' :
            ensure => file,
            source => 'puppet:///modules/scs/scs-runtime-hook-start',
            owner => root,
            group => root,
            mode => 0755,
            ;
    }

    exec {
        'apt-source:nginx/stable:key' :
            command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C',
            ;
        'apt-source:nginx/stable' :
            command => '/bin/echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu precise main" >> /etc/apt/sources.list',
            unless => '/bin/grep "deb http://ppa.launchpad.net/nginx/stable/ubuntu precise main" /etc/apt/sources.list',
            require => [
                Exec['apt-source:nginx/stable:key'],
            ],
            ;
        'apt-source:jenkins:key' :
            command => '/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -',
            ;
        'apt-source:jenkins' :
            command => '/bin/echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list',
            unless => '/bin/grep "deb http://pkg.jenkins-ci.org/debian binary/" /etc/apt/sources.list',
            require => [
                Exec['apt-source:jenkins:key'],
            ],
            ;
        'apt-update' :
            command => '/usr/bin/apt-get update',
            require => [
                Exec['apt-source:nginx/stable'],
                Exec['apt-source:jenkins'],
            ],
            ;
    }

    file {
        "/etc/nginx" :
            ensure => directory,
            ;
        "/etc/nginx/nginx.conf" :
            ensure => file,
            content => template('scs/nginx/nginx.conf.erb'),
            ;
        "/etc/supervisor.d/nginx.conf" :
            ensure => file,
            content => template('scs/nginx/supervisor.conf.erb'),
            ;
        "/var/log/nginx" :
            ensure => directory,
            ;
        "/var/run/nginx" :
            ensure => directory,
            ;

        "/etc/supervisor.d/jenkins.conf" :
            ensure => file,
            content => template('scs/jenkins/supervisor.conf.erb'),
            ;
        "/var/log/jenkins" :
            ensure => directory,
            ;

        "/usr/share/jenkins/plugins" :
            ensure => directory,
            require => [
                Package['jenkins'],
            ],
            ;
    }

    package {
        'nginx-light' :
            ensure => installed,
            require => [
                Exec['apt-source:nginx/stable'],
                Exec['apt-update'],
            ],
            ;
        'jenkins' :
            ensure => installed,
            require => [
                Exec['apt-source:jenkins'],
                Exec['apt-update'],
            ],
            ;
    }

    scs::plugin {
        'credentials' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/credentials/${plugin_credentials}/credentials.hpi"
            ;
        'git' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/git/${plugin_git}/git.hpi"
            ;
        'git-client' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/git-client/${plugin_git_client}/git-client.hpi"
            ;
        'greenballs' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/greenballs/${plugin_greenballs}/greenballs.hpi"
            ;
        'scm-api' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/scm-api/${plugin_scm_api}/scm-api.hpi"
            ;
        'subversion' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/subversion/${plugin_subversion}/subversion.hpi"
            ;
        'swarm' :
            source_hpi => "https://updates.jenkins-ci.org/download/plugins/swarm/${plugin_swarm}/swarm.hpi"
            ;
    }
}
