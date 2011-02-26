# Class: cyrus::imap
#
# This module manages cyrus imap server
#
# Parameters: 
#
# Actions:
#
# Requires:
#
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
    
    tool::setpass { 
        "cyrus": pwdhash => 'change_by_crypted_passwd'; 
    }
    
    
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
        
        file {
            "/etc/init.d/cyrus-imapd":
                source => "puppet:///cyrus/cyrus-imapd",
                sourceselect => all,
                mode    => 0755,
                owner   => "root",
                group   => "root",               
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
