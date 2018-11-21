# TIPFS -- The Telos IPFS Wrapper

The IPFS storage engine wrapper for the Telos blockchain.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

In order to use the TIPFS stack you need a few things:
 - Public IPv4 address mapped directly to a network interface ( No NAT. No Exceptions! )
 - Linux instance running Ubuntu 18.04
 - Service account without sudo privileges

### Installing

Create service account

```
groupadd ipfs && useradd -d /home/ipfs -g ipfs -m -s /bin/bash ipfs
```

Enter service account

```
sudo su -l ipfs
```

Bootstrap node

```
curl "https://raw.githubusercontent.com/Telos-Foundation/tipfs/master/install.sh" | bash
```

When this is finished, you should have a running IPFS node connected to our swarm.  You can verify by issuing
```
ipfs swarm peers
```

## Options

### `--prefix`

Set the install prefix.  By default, the prefix is set to the home folder of the service account.  Make sure the service account has privileges to modify this path.

`Example --prefix /srv/ipfs`

``

Todo

## Authors

* **Stephanie Sunshine** - [StephanieSunshine](https://github.com/StephanieSunshine)
* **John Hauge** - [JohnHauge](https://github.com/jhexperiment)
* **Lee Hundley** - [LeeHundley](https://github.com/initpnw)

See also the list of [contributors](https://github.com/Telos-Foundation/tipfs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
