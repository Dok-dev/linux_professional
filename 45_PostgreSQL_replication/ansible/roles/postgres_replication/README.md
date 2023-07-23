# Ansible role `postgres_replication`

Ansible role for configure replication for PostgreSQL cluster on Centos Sream8.

## Requirements

* Ansible 2.9.13+

## Variables

| Variable                             | Comment                                                                                                  | Required | Example/Default       |
|:-------------------------------------|----------------------------------------------------------------------------------------------------------|:--------:|-----------------------|
| `master_ip`                          | Master node IP adress.                                                                                   | yes      | `192.168.57.11`       |
| `slave_ip`                           | Slave node IP adress.                                                                                    | yes      | `192.168.57.12`       |
| `replicator_password`                | Replicator user password.                                                                                | yes      | `Otus2022!`           |


## Dependencies

community.postgresql

## Example Playbook

Available variables are listed below, along with default values (see `./defaults/main.yml`).

### Installation and Usage

Include a role in `requirements.yml` file:

Install the role using the command: `ansible-galaxy install -r requirements.yml`.


## License

MIT/BSD

## Supported OS

* centos/stream8
