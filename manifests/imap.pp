# Class: cyrus::imap
#
# This module manages cyrus imap server
#
# Parameters: 
#
# Actions:
#
# Requires: to have a nice master/slave setup that really works as
#           expected, cyrus-imapd-2.4.6 is needed.
#           You can find the src file here: http://www.invoca.ch/pub/packages/cyrus-imapd/cyrus-imapd-2.4.6-5.src.rpm
# Sample Usage:
#
# Cluster ? This can be configured as a two node cluster if you define
# (for ex in puppetdashboard, nodes.pp or foreman) $cluster_bind_interface
class cyrus::imap {
    package {
        "cyrus-imapd.$hardwaremodel":
            alias => "cyrus-imapd",
            ensure => installed,
    }
    
    service { "cyrus-imapd":
        enable     => false,
        hasrestart => true,
        hasstatus  => true,
        require    => Package["cyrus-imapd"];
    }
    
    realize(
        User["cyrus"],
    )
    
    
    if $cluster_bind_interface {
    
        $tmp_nic = "ipaddress_${cluster_bind_interface}"
        $bindnetaddr = inline_template("<%= scope.lookupvar(tmp_nic) %>")  
        
        file {
            "/etc/cyrus.conf-master":
            ensure  => present,
            content  =>  template("cyrus/cluster/cyrus.conf-master.erb"),
            require =>  Service["cyrus-imapd"];
        }
    
        file {
            "/etc/cyrus.conf-slave":
            ensure  => present,
            content  =>  template("cyrus/cluster/cyrus.conf-slave.erb"),
            require =>  Service["cyrus-imapd"];
        }
        
        file {
            "/etc/imapd.conf-master":
            ensure  => present,
            content  =>  template("cyrus/cluster/imapd.conf-master.erb"),
            require =>  Service["cyrus-imapd"];
        }
        
        file {
            "/etc/imapd.conf-slave":
            ensure  => present,
            content  =>  template("cyrus/cluster/imapd.conf-slave.erb"),
            require =>  Service["cyrus-imapd"];
        }
        
     }
     else {
     
        file {
            "/etc/cyrus.conf":
            ensure  => present,
            source  => [
                        "puppet:///cyrus/$hostname/cyrus.conf",
                        "puppet:///cyrus/default/cyrus.conf",
                       ],
            require =>  Service["cyrus-imapd"];
        }
    
        file {
            "/etc/imapd.conf":
            ensure  => present,
            source  => [
                        "puppet:///cyrus/$hostname/imapd.conf",
                        "puppet:///cyrus/default/imapd.conf",
                       ],
            require =>  Service["cyrus-imapd"];
        }
        
     }
}
