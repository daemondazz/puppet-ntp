# NTP module for Puppet

This is puppet module for configuring NTP on servers. It defines a new type, called ntp, that provides the required functionality. This is designed to be instantiated into the base node with the FQDN as part of the instance name so that variables can be over-ridden on a per node basis as required. This is a work around for puppet not allowing classes inherited from parents to be overridden.

Currently only tested on Debian/Ubuntu and RedHat/CentOS based servers.


## Puppet Types

1. `ntp`

   Object that performs the configuration of the NTP service on the node. Supports the following options:

      * `servers` (array)

          The list of upstream NTP servers for the node (generates server lines)

      * `restrict` (array)

          The list of trusted clients for this node (generates restrict lines)

      * `keysfile` (string)

          The location of the key file for this node (generates the keysfile line)

      * `driftfile` (string)

          The location of the drift file for this node (generates the driftfile line)

      * `preferred_servers` (array)

          A list of the preferred servers for this node (Adds the 'prefer' keyword to servers in the `servers` list)

## Examples

### site.pp

This snippet includes the NTP class into the default node, which is inherited by all nodes. This ensures that all servers are configured for NTP, using our set of internal servers. It also defines a variable which contains the NTP servers that our internal NTP servers use themselves:


    node default {
        $ntp_service_servers = [ 'ntp0.cs.mu.oz.au',
                                 'ntp1.cs.mu.oz.au',
                                 'clock.via.net',
                                 'time.nist.gov',
                                 'ntp.on.net',
                                 'time.deakin.edu.au' ]
        ntp { "ntp_${fqdn}" :
            servers   => [ 'ntp1.afoyi.com', 'ntp2.afoyi.com', 'ntp3.afoyi.com' ],
            restrict  => [ '172.17.1.2', '103.1.212.18', '10.254.254.5', '2403:4200:403:2::5' ],
        }
    }

### node

This snippet demonstrates overriding ones of the variables, such as the server list, for a single node, such as the NTP servers listed in the default node:

    node "ntp1.afoyi.com" {
        Ntp["ntp_$fqdn"] { 
            servers => $ntp_service_servers
        }
    }

