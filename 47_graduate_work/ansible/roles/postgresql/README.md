# Ansible role `postgresql`

Ansible role for installation and configuration of PostgreSQL DB on Centos Sream8.

## Requirements

* Ansible 2.9.13+

## Variables

| Variable                             | Comment                                                                                                  | Required | Example/Default       |
|:-------------------------------------|----------------------------------------------------------------------------------------------------------|:--------:|-----------------------|
| `postgres_users_no_log`              | Whether to output user data (which may contain sensitive information like passwords) when managing users | yes      | `true`                |
| `postgresql_databases`               | List of databases to ensure exist on the server                                                          | yes      | See example below     |
| `postgresql_global_config_options`   | Global configuration options that will be set in `postgresql.conf`                                       | yes      | See example below     |
| `postgresql_group`                   | The group under which PostgreSQL will run                                                                | yes      | `postgres`            |
| `postgresql_hba_entries`             | Configures host based authentication entries to be set in the `pg_hba.conf`                              | yes      | See example below     |
| `postgresql_packages`                | Versions of dependent packages                                                                           | yes      | See example below     |
| `postgresql_unix_socket_directories` | The directories (usually one, but can be multiple) where PostgreSQL's socket will be created             | yes      | `/var/run/postgresql` |
| `postgresql_user`                    | The user under which PostgreSQL will run                                                                 | yes      | `postgres`            |
| `postgresql_users`                   | List of users to ensure exist on the server                                                              | yes      | See example below     |
| `postgresql_version`                 | Version of PostgreSQL                                                                                    | yes      | See example below     |

## Dependencies

None

## Example Playbook

Available variables are listed below, along with default values (see `./defaults/main.yml`).

### Installation and Usage

Include a role in `requirements.yml` file:

Install the role using the command: `ansible-galaxy install -r requirements.yml`.

### General example


```YAML
---
- hosts: postgresql
  become: true
  vars:
    ansible_python_interpreter: /usr/bin/python3
    postgresql_hba_entries:
      - { type: local, database: all, user: postgres, auth_method: peer }
      - { type: local, database: all, user: all, auth_method: peer }
      - { type: host, database: all, user: all, address: '127.0.0.1/32', auth_method: md5 }
      - { type: host, database: all, user: all, address: '::1/128', auth_method: md5 }
    postgresql_locales:
      - 'en_US.UTF-8'
    postgresql_users:
      - name: test_user
        password: 12345678
        state: present
    postgresql_databases:
      - name: test_db
        owner: test_user
        state: present
    postgres_users_no_log: false
  roles:
    - postgresql

```

### Global configuration options

Global configuration options that will be set in `postgresql.conf`. String values are specified in quotes, other values without them.

```YAML
postgresql_global_config_options:
  - option: unix_socket_directories
    value: '{{ postgresql_unix_socket_directories | join(",") }}'
  - option: log_duration
    value:  on
  - option: log_min_duration_statement
    value: -1
```

### Configure host based authentication

Configure host based authentication entries to be set in the `pg_hba.conf`.

```YAML
postgresql_hba_entries:
  - { type: local, database: all, user: postgres, auth_method: peer }
  - { type: local, database: all, user: all, auth_method: peer }
  - { type: host, database: all, user: all, address: '127.0.0.1/32', auth_method: md5 }
  - { type: host, database: all, user: all, address: '::1/128', auth_method: md5 }
```

Options for entries include:

* `type` (required)
* `database` (required)
* `user` (required)
* `address` (one of this or the following two are required)
* `ip_address`
* `ip_mask`
* `auth_method` (required)
* `auth_options` (optional)

If overriding, make sure you copy all of the existing entries from `defaults/main.yml` if you need to preserve existing entries.

### Generate the locales used by PostgreSQL databases

```YAML
postgresql_locales:
  - 'en_US.UTF-8'
```

### A list of databases to ensure exist on the server

Only the name is required; all other properties are optional.

```YAML
postgresql_databases:
  - name: exampledb # required; the rest are optional
    lc_collate: # defaults to 'en_US.UTF-8'
    lc_ctype: # defaults to 'en_US.UTF-8'
    encoding: # defaults to 'UTF-8'
    template: # defaults to 'template0'
    login_host: # defaults to 'localhost'
    login_password: # defaults to not set
    login_user: # defaults to 'postgresql_user'
    login_unix_socket: # defaults to 1st of postgresql_unix_socket_directories
    port: # defaults to not set
    owner: # defaults to postgresql_user
    state: # defaults to 'present'
```

### A list of users to ensure exist on the server

Only the name is required, all other properties are optional.

```YAML
postgresql_users:
  - name: jdoe #required; the rest are optional
    password: # defaults to not set
    encrypted: # defaults to not set
    priv: # defaults to not set
    role_attr_flags: # defaults to not set
    db: # defaults to not set
    login_host: # defaults to 'localhost'
    login_password: # defaults to not set
    login_user: # defaults to '{{ postgresql_user }}'
    login_unix_socket: # defaults to 1st of postgresql_unix_socket_directories
    port: # defaults to not set
    state: # defaults to 'present'
```

## Testing

```Bash
# Go to tests directory
cd postgresql/tests
# Deploy virtual machines
vagrant up
```

## License

MIT/BSD

## Supported OS

* centos/stream8
