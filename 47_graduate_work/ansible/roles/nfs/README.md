NFS
=========

A simple NFS server and client playbook.

Requirements
------------

None

Role Variables
--------------

`nfs_fstype` is the type of filesystem to create on the disk. Optional, default "xfs".

`nfs_export` is the path to exported filesystem mountpoint on the NFS server. Optional, default "/srv".

`nfs_export_subnet` is the host or network to which the export is shared. Optional, "*".

`nfs_export_options` are the options to apply to the export. Optional, default "rw,insecure,no_root_squash".

`nfs_client_mnt_point` is the path to the mountpoint on the NFS clients. Optional, default "/mnt".

`nfs_client_mnt_options` allows passing mount options to the NFS client. Optional, default omits this.

`nfs_server` is the IP address or hostname of the NFS server.

`nfs_enable`: a mapping with keys `server` and `client` - values are bools determining the role of the host.

Dependencies
------------

None

Example Playbook
----------------


License
-------

BSD
