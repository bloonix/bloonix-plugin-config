# Bloonix Plugin Configuration Files

## About Bloonix

For general information about Bloonix, questions, ratings or other things please visit our base repository:

* https://github.com/bloonix/bloonix

## Bloonix Plugins

Ordered by id (desc)

      id   |             plugin              |          command          
    -------+---------------------------------+---------------------------
        69 | SNMP.Walk.Check                 | check-snmp-walk
        68 | SNMP.Check                      | check-snmp
        67 | SNMP.ServiceCheck               | check-snmp-service
        66 | SNMP.ProcessCheck               | check-snmp-process
        65 | SNMP.NumberOfProcesses          | check-snmp-nprocs
        64 | SNMP.Memory                     | check-snmp-mem
        63 | SNMP.Disk                       | check-snmp-disk
        62 | SNMP.CPU                        | check-snmp-cpu
        61 | Linux.RAID.LSI.Check            | check-lsi-raid
        60 | Customer.BloonixSatellite.Check | check-bloonix-satellite
        59 | Nagios.Wrapper                  | check-nagios-wrapper
        58 | WebTransaction                  | check-wtrm
        57 | Windows.SNMP.Service            | check-win-snmp-service.pl    (deprecated)
        56 | Windows.SNMP.ProcessCheck       | check-win-snmp-process.pl    (deprecated)
        55 | Windows.SNMP.NumberOfProcesses  | check-win-snmp-nprocs.pl     (deprecated)
        54 | Windows.SNMP.Memory             | check-win-snmp-mem.pl        (deprecated)
        53 | Windows.SNMP.Disk               | check-win-snmp-disk.pl       (deprecated)
        52 | Windows.SNMP.CPU                | check-win-snmp-cpu.pl        (deprecated)
        51 | Varnish.Check                   | check-varnish3
        50 | Linux.Sensors                   | check-lm-sensors
        49 | Redis.Queue.Check               | check-redis-queue
        48 | Redis.Check                     | check-redis
        47 | Postfix.Mailqueue               | check-postfix-mailqueue
        46 | PostgreSQL.ProcessStatus        | check-pgsql8-procs
        45 | PostgreSQL.DatabaseStatus       | check-pgsql8-db
        44 | Nginx.Check                     | check-nginx
        43 | MySQL.SlaveStatus               | check-mysql-slave
        42 | MySQL5.Status                   | check-mysql5
        41 | Memcached.Check                 | check-memcached
        40 | Linux.Socket.Check              | check-sockstat
        39 | Linux.Smart.Health              | check-smart-health
        38 | Linux.Service.Check             | check-service
        36 | Linux.Processes.Check           | check-procstat
        35 | Ping.Check                      | check-ping
        34 | Linux.Paging.Check              | check-pgswstat
        33 | Linux.OpenFiles.Check           | check-open-files
        32 | Linux.NFS4Client.Check          | check-nfs4-client
        31 | Linux.NFS4Server.Check          | check-nfs4
        30 | Linux.NFS3.Check                | check-nfs3
        29 | Linux.NetstatPort.Check         | check-netstat-port
        28 | Linux.Netstat.Check             | check-netstat
        27 | Network.MTR.Check               | check-mtr
        26 | Linux.Memory.Check              | check-memstat
        25 | Linux.MDADM.Check               | check-mdadm
        24 | Linux.LoadAVG.Check             | check-loadavg
        23 | Linux.Updates.Check             | check-linux-updates
        22 | Linux.DiskIO.Check              | check-iostat
        21 | Linux.Interface.Statistics      | check-ifstat
        20 | Linux.Interface.Check           | check-iflink
        19 | Linux.Disk.Check                | check-diskusage
        18 | Linux.CPU.Check                 | check-cpustat
        17 | Linux.Bonding.Check             | check-bonding
        16 | Lighttpd.Status                 | check-lighttpd
        15 | Linux.DRBD.Check                | check-drbd
        14 | UDP.Check                       | check-udp
        13 | TCP.Check                       | check-tcp
        12 | SNMP.Interface                  | check-snmp-if
        11 | SMTP.Check                      | check-smtp
        10 | POP3.Check                      | check-pop3
         9 | Logfile.Check                   | check-logfile
         8 | IMAP.Check                      | check-imap
         7 | HTTP.Check                      | check-http
         6 | FTP.Check                       | check-ftp
         5 | Filestat.Check                  | check-filestat
         4 | DNS.Check                       | check-dns
         3 | Database.Check                  | check-dbconnect
         2 | Cluster.ServiceCheck            | check-cluster
         1 | Apache2.Statistics              | check-apache2
