# Ansible role `barman`
=========

Ansible role for installation and configuration of Barman backup on Centos Sream8.

## Requirements

* Ansible 2.9.13+

## Variables

| Variable                             | Comment                                                                                                  | Required | Example/Default       |
|:-------------------------------------|----------------------------------------------------------------------------------------------------------|:--------:|-----------------------|
| `master_ip`                          | Master node address                                                                                      | yes      | `192.168.57.11`       |
| `barman_ip`                          | Barman node address                                                                                      | yes      | `192.168.57.13`       |
| `master_user`                        | PostgreSQL administrator login                                                                           | yes      | 'postgres'            |
| `barman_user`                        | Back up PostgreSQL user                                                                                  | yes      | `barman`              |
| `barman_user_password`               | Back up PostgreSQL user password                                                                         | yes      | 'zGdgq3^5'            |


## Dependencies

None

## Example Playbook

Available variables are listed below, along with default values (see `./defaults/main.yml`).

### Installation and Usage

Include a role in `requirements.yml` file:

Install the role using the command: `ansible-galaxy install -r requirements.yml`.

License
-------

BSD

Author Information
------------------
