# Pacemaker role for Ansible

This role configures Pacemaker cluster by dumping the configuration (CIB), adjusting the XML, and
reloading it. The role is idempotent, and supports check mode.

It has been redesigned to configure individual elements (cluster defaults, resources, groups,
constraints, etc) rather than the whole state of the cluster and all the services. This allows you
to focus on specific resources, without interfering with the rest.

## Requirements

This role has been written for and tested in CentOS 8. It might also work in other
distros, please share your experience.

## Tasks

Use `tasks_from` Ansible directive to specify what you want to configure.

Boolean values in properties (parsed by Pacemaker itself) don't have to be quoted. However,
resource agents may expect Boolean-like arguments as integers, strings, etc. Such values **must**
be quoted.

### `tasks_from: main`

Set up nodes, configure cluster properties, and resource defaults.

#### `pcmk_cluster_name`

Name of the cluster (optional).

Default: `hacluster`.

#### `pcmk_password`

The plaintext password for the cluster user (optional). If omitted, will be derived from
`ansible_machine_id` of the first host in the play batch. This password is only used in the initial
authentication of the nodes.

Default: `ansible_machine_id | to_uuid`

#### `pcmk_user`

The system user to authenticate PCS nodes with (optional). PCS will authenticate all nodes with
each other.

Default: `hacluster`

#### `pcmk_cluster_options`

Dictionary with [cluster-wide options](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/s-cluster-options.html) (optional).

#### `pcmk_votequorum`

Dictionary with votequorum options (optional). See `votequorum(5)`. Boolean values accepted.

#### `pcmk_resource_defaults`

Dictionary of resource defaults (optional).

### `tasks_from: resource`

Configure a simple resource.

#### `pcmk_resource`

Dictionary describing a simple (*primitive*) resource. Contains the following members:

* `id`: resource identifier; mandatory for simple resources;
* `class`, `provider`, and `type`: resource agent descriptors; `provider` may be omitted, e.g. when
  `type` is `service`;
* `options`: optional dictionary of resource-specific attributes, e.g. address and netmask for
  *IPaddr2*;
* `op`: optional list of operations; each operation is a dictionary with required `name` and
  `interval` members, and optional arbitrary members;
* `meta`: optional dictionary of meta-attributes.

### `tasks_from: group`

Configure a resource group.

#### `pcmk_group`

Dictionary with two members:

* `id` is the group identifier
* `resources` is a dictionary where keys are resource IDs, and values have the same format as
  `pcmk_resource` (except for `id` of the resources being optional).

### `tasks_from: constraint`

Configure a constraint.

##### `pcmk_constraint`

Dictionary defining a single constraint. The following members are required:

* `type`: one of: `location`, `colocation`, or `order`;
* `score`: constraint score (signed integer, `INFINITY`, or `-INFINITY`).

Depending on the value of `type`, the following members are also required:

* `location` requires `rsc` and `node`;
* `colocation` requires `rsc` and `with-rsc`;
* `order` requires `first` and `then`;

The dictionary may contain other members, e.g. `symmetrical`.

## Example playbooks
### Pacemaker cluster

The following requirements are specific requirements for cluster setup.

#### Number of Nodes

-   Up to 16 nodes per cluster.
-   Minimum number of nodes: 3.
-   2 nodes cluster could be configured but is not recommended.

### OS requirements

The following requirements are specific to OS deployments.

#### macOS

-   [Python passlib module](http://docs.ansible.com/ansible/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module)

```bash
pip install passlib
```

## Role Variables

```yaml
---
# defaults file for ansible-pacemaker
corosync_authkey_file: '/etc/corosync/authkey'

# Defines interface used for cluster
corosync_bindnet_interface: 'eth1'

corosync_config_file: '/etc/corosync/corosync.conf'

# Defines the number of nodes to be functional in order to avoid split-brain
# scenarios...ex. 2-nodes = 1, 3-nodes = 2
corosync_expected_votes: "{{ ( groups[pacemaker_cluster_group]|count /2 ) | round (0, 'ceil') | int }}"

# Corosync itself works without a cluster name, but DLM needs one.
# The cluster name is also written into the VG metadata of newly
# created shared LVM volume groups, if lvmlockd uses DLM locking.
# It is also used for computing mcastaddr, unless overridden below.
corosync_cluster_name: 'corosync'

# Setting corosync_last_man_standing to true enables the Last Man Standing (LMS) feature;
# by default, it is disabled (set to false)
corosync_last_man_standing: true

# Define multicast address to use for cluster
# this should be unique per cluster
corosync_mcastaddr: 239.255.42.1

# Define port number to configure as cluster port.
corosync_mcastport: 5405

# Defines if unicast mode should be used rather than multicast
corosync_unicast_mode: false

# Means that, When starting up a cluster (all nodes down), the cluster quorum
# is held until all nodes are online and have joined the cluster for the first
# time. This parameter is new in Corosync 2.0.
corosync_wait_for_all: true

pacemaker_cluster_constraints: []
  # - constraint: 'colocation'
  #   action: 'add'
  #   source_resource_id: 'webserver'
  #   target_resource_id: 'virtual_ip'
  #   score: 'INFINITY'
  # - constraint: 'order'
  #   order:
  #     first_resource: 'virtual_ip'
  #     first_resource_action: 'start'
  #     second_resource: 'webserver'
  #     second_resource_action: 'start'

pacemaker_cluster_group: 'ha_cluster'

pacemaker_cluster_resources: []
  # - resource_id: 'virtual_ip'
  #   action: 'create'
  #   provider: 'ocf:heartbeat:IPaddr2'
  #   options:
  #     - 'ip=192.168.250.200'
  #     - 'cidr_netmask=24'
  #   op: 'monitor'
  #   op_options:
  #     - 'interval=30s'
  # - resource_id: 'webserver'
  #   action: 'create'
  #   provider: 'ocf:heartbeat:nginx'
  #   options:
  #     - 'configfile=/etc/nginx/nginx.conf'
  #   op: 'monitor'
  #   op_options:
  #     - 'timeout=5s'
  #     - 'interval=5s'

# NOT RECOMMENDED FOR PRODUCTION!!!!!
# You must have a STONITH device to enable....
pacemaker_disable_stonith: true

# Define specific cluster settings to configure
pacemaker_cluster_settings: []
  # - property: 'start-failure-is-fatal'
  #   value: 'false'
  # - property: 'pe-warn-series-max'
  #   value: 1000
  # - property: 'pe-input-series-max'
  #   value: 1000
  # - property: 'pe-error-series-max'
  #   value: 1000
  # - property: 'cluster-recheck-interval'
  #   value: 5min

# Define hacluster user password for webUI
#
# Generate new password
# echo "haclusteradmin" | sha512sum
pacemaker_hacluster_password: 'f8d1feb7105dfbd2859a17512c7414f89b70dfef815b177444b897edec19a18724f8e9686f0e2daa41c48eb9b0511bae9e659a756f17c39fedb6d68b9230a53c'

# Defines if host is considered to be primary
# this should be set in host_vars/hostname as true for only one host
pacemaker_primary_server: '{{ groups[pacemaker_cluster_group][0] }}'
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: ha_cluster
  vars:
    etc_hosts_add_all_hosts: true
    pacemaker_cluster_constraints:
      - constraint: 'colocation'
        action: 'add'
        source_resource_id: 'webserver'
        target_resource_id: 'virtual_ip'
        score: 'INFINITY'
      - constraint: 'order'
        order:
          first_resource: 'virtual_ip'
          first_resource_action: 'start'
          second_resource: 'webserver'
          second_resource_action: 'start'
    pacemaker_cluster_resources:
      - resource_id: 'virtual_ip'
        action: 'create'
        provider: 'ocf:heartbeat:IPaddr2'
        options:
          - 'ip=192.168.250.200'
          - 'cidr_netmask=24'
        op: 'monitor'
        op_options:
          - 'interval=30s'
      - resource_id: 'webserver'
        action: 'create'
        provider: 'ocf:heartbeat:nginx'
        options:
          - 'configfile=/etc/nginx/nginx.conf'
        op: 'monitor'
        op_options:
          - 'timeout=5s'
          - 'interval=5s'
    pacemaker_cluster_settings:
      - property: 'start-failure-is-fatal'
        value: 'false'
      - property: 'pe-warn-series-max'
        value: 1000
      - property: 'pe-input-series-max'
        value: 1000
      - property: 'pe-error-series-max'
        value: 1000
      - property: 'cluster-recheck-interval'
        value: 5min
    pri_domain_name: 'test.vagrant.local'
  roles:
    - role: ansible-apt-sources
    - role: ansible-motd
    - role: ansible-ntp
    - role: ansible-timezone
      become: true
    - role: ansible-etc-hosts
    - role: ansible-pacemaker
      tags:
        - pacemaker
    - role: ansible-nginx
  tasks:
```

## License

BSD

## Author Information
