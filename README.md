# CentOS Linux for Vagrant

Packer templates to build a small CentOS Linux box designed for use in Vagrant.

## What is CentOS?

> The CentOS Project is a community-driven free software effort focused on delivering a robust open source ecosystem. For users, we offer a consistent manageable platform that suits a wide variety of deployments. For open source communities, we offer a solid, predictable base to build upon, along with extensive resources to build, test, release, and maintain their code.

*from* [centos.org](https://www.centos.org)

## Synopsis

This is a set of templates designed for use with Packer to create Vagrant
boxes with CentOS installed.

All non-required packages were removed to create this small box. When using
this box you may have to install some of the packages that usually are
installed on a regular CentOS Linux Vagrant box.

## Getting Started

There are a couple of things needed for the templates to work.

### Prerequisites

Packer, Vagrant, Virtualbox, and VMWare need to be installed on your local
computer.

#### Packer

Packer installation instructions can be found
[here](https://www.packer.io/docs/install).

#### Vagrant

Vagrant installation instructions can be found
[here](https://www.vagrantup.com/docs/installation).

#### Virtualbox

Virtualbox installation instructions can be found
[here](https://www.virtualbox.org/wiki/Downloads).

As of CentOS Stream release 8 Virtualbox 6.1.27 or higher is required.

#### VMware

VMware installation instructions will depend on the VMware product that you
want. Go to the desired product page at [VMware](https://www.vmware.com) and
check for the appropriate documentation.

Vagrant support for the VMWare hypervisor is provided by the `Vagrant VMWare
Utility` that can be downloaded from [here](https://www.vagrantup.com/vmware/downloads).
and by the `Vagrant VMware provider` that can be installed by running the
following command on a terminal:

```shell
vagrant plugin install vagrant-vmware-desktop
```

## Usage

To create a virtual machine using this box create a folder and run the
following command inside that folder:

```shell
vagrant init fscm/centos
```

To start that virtual machine run:

```shell
vagrant up
```

This box is available for multiple providers. See the table below to find out
how to run a specific provider.

|  provider  |  command                               |
|------------|----------------------------------------|
| virtualbox | `vagrant up --provider=virtualbox`     |
| vmware     | `vagrant up --provider=vmware_desktop` |

## Build

In order to create a CentOS Linux Vagrant box using this Packer recipe you need
to run the following `packer` command on the root of this project:

```shell
packer build [-var 'option=value'] <VARIANT>
```

- `<VARIANT>` - *[required]* The variant that is being build (`stream8`).

Options:

- `disk_size_mb` - The disk size in megabytes (default value:8192).
- `debug` - Enable debug (default value:false).
- `domain` - The network domain (default value:"vagrant.local").
- `hostname` - The system hostname (default value:"centos").
- `os_version` - The OS version (default value:"8").
- `password` - The password for the user (default value:"stream").
- `username` - The username for the user (default value:"stream").

The recipe will, by default, build a box for every supported provider. To build
only for the desired one(s) use the `-only` packer option.

List of supported providers:

|  provider  |  option                           |
|------------|-----------------------------------|
| virtualbox | `-only=virtualbox-iso.virtualbox` |
| vmware     | `-only=vmware-iso.vmware`         |

More than one provider can be specified by separating the names with commas
(e.g.: `-only=virtualbox-iso.virtualbox,vmware-iso.vmware`).

A build example:

```shell
packer build -only=vmware-iso.vmware -var 'debug=true' stream8
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for more details on how
to contribute to this project.

## Versioning

This project uses [SemVer](http://semver.org/) for versioning. For the versions
available, see the [tags on this repository](https://github.com/fscm/packer-vagrant-centos/tags).

## Authors

- **Frederico Martins** - [fscm](https://github.com/fscm)

See also the list of [contributors](https://github.com/fscm/packer-vagrant-centos/contributors)
who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details
