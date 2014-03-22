define scs::plugin (
    $source_hpi = undef,
) {
    if undef != $source_hpi {
        $source = $source_hpi
    } else {
        $source = "https://updates.jenkins-ci.org/latest/${name}.hpi"
    }

    exec {
        "plugin:${name}:download" :
            command => "/usr/bin/wget -qO /usr/share/jenkins/plugins/${name}.hpi \"\$DOWNLOAD\"",
            environment => [
                "DOWNLOAD=${source}",
            ],
            creates => "/usr/share/jenkins/plugins/${name}.hpi",
            require => [
                File["/usr/share/jenkins/plugins"],
            ],
            ;
    }
}
