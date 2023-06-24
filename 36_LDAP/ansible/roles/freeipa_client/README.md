# Ansible role `freeipa_client`

Ansible role for deployment of FreeIPA clients on CentOS 8.

## Requirements

* Ansible >=2.10.2, <2.14
* Python 3.8


## Role Variables

| Variable                              | Comment                                                       | Required | Example/Default        |
|:--------------------------------------|---------------------------------------------------------------|:--------:| -----------------------|
| `freeipa_client_fqdn`                 | FreeIPA client FQDN                                           | yes      | `client01.example.com` |
| `freeipa_client_realm`                | REALM (in uppercase)                                          | yes      | `EXAMPLE.COM`          |
| `freeipa_client_master_fqdn`          | FreeIPA master server FQDN                                    | yes      | `dc01.example.com`     |
| `freeipa_client_domain`               | FreeIPA domain                                                | yes      | `example.com`          |
| `freeipa_client_ip`                   | Client IP Address (you can use `{{ ansible_host }}` variable) | yes      | `192.168.10.21`        |
| `freeipa_client_principal`            | FreeIPA server admin principal                                | yes      | `admin`                |
| `freeipa_client_password`             | FreeIPA admin password                                        | yes      | `12345678`             |
| `freeipa_client_manage_host`          | Configure hostname and add `/etc/hosts` line                  | yes      | `true`                 |
| `freeipa_client_dns_updates`          | Enable DNS updates                                            | yes      | `true`                 |
| `freeipa_ntp_server`                  | NTP server address                                            | yes      | `ntp.ix.ru`            |
| `freeipa_master_server_ip`            | FreeIPA master server IP                                      | no       | `192.168.100.1` *      |
| `freeipa_client_additional_resolv_ns` | Additional DNS for client                                     | yes      | `8.8.8.8`, `77.8.8.8`  |
| `freeipa_client_no_log` | Disable logging for sensitive commands                                      | no       | `true`  |

* If freeipa_master_server_ip is not set or fails validation, the role tries to get the value from inventory file group [freeipa_server]

## Example Playbook

```YAML
- hosts: some-host
  become: true
  roles:
    - freeipa_client
```


## License

BSD

## Author Information

Timofey Biriukov
