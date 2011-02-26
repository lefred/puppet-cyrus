# Class: cyrus::sasl
#
# This module manages cyrus sasl 
#
# Parameters: 
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class cyrus::sasl {

    package {
        "cyrus-sasl.$hardwaremodel":
            alias => "cyrus-sasl",
            ensure => installed, 
    }
    
    service { "saslauthd":
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package["cyrus-sasl"];
    }
}
