# Ansible role `freeipa_server`

Ansible role for deployment of FreeIPA server on CentOS 8.

## Requirements

* Ansible >=2.10.2, <2.14
* Python 3.8

The following Python3 modules must be exported for offline installation:

| Package        | Version |
|:---------------|:-------:|
| `pexpect`      | 4.8.0   |
| `cryptography` | 3.2.1   |
| `pyopenssl`    | 20.0.1  |
| `python-ldap`  | 3.3.1   |


## Role variables

| Variable                                     | Comment                                                                        | Required | Example/Default                |
| -------------------------------------------- | ------------------------------------------------------------------------------ | :------: | ------------------------------ |
| `freeipa_server_admin_password`              | FreeIPA admin password                                                         | yes      | `12345678`                     |
| `freeipa_server_domain`                      | Primary DNS domain of the IPA deployment                                       | yes      | `example.com`                  |
| `freeipa_server_ds_password`                 | FreeIPA server 389 Directory Server admin password                             | yes      | `12345678`                     |
| `freeipa_server_realm`                       | Kerberos realm name of the IPA deployment (in uppercase)                       | yes      | `EXAMPLE.COM`                  |
| `freeipa_server_manage_host`                 | Configure hostname and add `/etc/hosts` line                                   | no       | `true`                         |
| `freeipa_server_ip`                          | Replica server IP address                                                      | no       | `{{ ansible_host }}`           |
| `freeipa_server_install_dns`                 | Configure bind with our zone                                                   | no       | `true`                         |
| `freeipa_server_allow_forwarders`            | Allow add a DNS forwarder                                                      | no       | `false`                        |
| `freeipa_server_global_dns_forwarder`        | List of Global DNS forwarders                                                  | no       | `8.8.8.8`, `77.88.8.8`         |
| `freeipa_server_dns_forwarder`               | Address of DNS forwarder, add a DNS forwarder                                  | no       | `8.8.8.8`                      |
| `freeipa_server_custom_dns`                  | Address of DNS, that will be use before FreeIPA installation                   | no       | `8.8.8.8`                      |
| `freeipa_server_dns_autoforwarder`           | Use DNS forwarders configured in `etc/resolv.conf`                             | no       | `true`                         |
| `freeipa_server_auto_reverse`                | Create necessary reverse zones                                                 | no       | `true`                         |
| `freeipa_server_enable_dns_recursion_policy` | Allow DNS recursion                                                            | no       | `false`                        |
| `freeipa_server_setup_kra`                   | Configure a dogtag KRA                                                         | no       | `true`                         |
| `freeipa_crt_key_passphrase`                 | FreeIPA private keys passphrase (Smolensk install without dogtag KRA)          | no       | `12345678`                     |
| `freeipa_server_allow_zone_overlap`          | Create DNS zone even if it already exists                                      | no       | `false`                        |
| `freeipa_pip_repo_url`                       | Pip repository location for offline install                                    | no       | `http://192.168.17.3/pip-repo` |
| `freeipa_pip_repo_trusted_host`              | The server of self-hosted repository usually needs to be added to trusted list | no       | `192.168.17.3`                 |
| `freeipa_server_set_extended_repo`           | Setup extended repo for ALSE                                                   | no       | `false`                        |
| `freeipa_tune_search_size_limit`             | Increases searchrecords limit                                                  | no       | `false`                        |
| `freeipa_tune_max_file_descriptors`          | Increases file descriptors                                                     | no       | `false`                        |
| `freeipa_tune_krb5_kdc_tune`                 | Adjusting the number of krb5kdc processes                                      | no       | `false`                        |
| `freeipa_tune_sasl_tune`                     | Increases buffer size SASL in LDAP                                             | no       | `false`                        |
| `freeipa_tune_nsslapd_sasl_max_buffer_size`  | Buffer size SASL in LDAP                                                       | no       | `10485760`                     |
| `freeipa_tune_nsslapd_maxdescriptors`        | Nsslapd max descriptors                                                        | no       | `16384`                        |
| `freeipa_tune_nofile_soft_limit`             | Nofile soft limit                                                              | no       | `16384`                        |
| `freeipa_tune_nofile_hard_limit`             | Nofile hard limit                                                              | no       | `1048576`                      |
| `freeipa_tune_hide_userpassword_field`       | Disables capability to read userPassword field                                 | no       | `false`                        |

## Dependencies

None

## Example Playbook

```YAML
- hosts: some-host
  become: true
  roles:
    - freeipa_server
```

In `ansible.cfg` you must specify python interpreter:

```ini
interpreter_python = /usr/bin/python3
```

In inventory file, specify host and user.

Example:

```ini
[freeipa_server]
ipa-dc01 ansible_host=10.0.50.2 ansible_user=vagrant
```

## License

BSD

## Author Information

Timofey Biriukov
