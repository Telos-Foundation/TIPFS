# TIPFS: The IPFS Wrapper for the Telos Network

The IPFS storage engine wrapper for the Telos blockchain.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

In order to use the TIPFS stack you need a few things:
* Public IPv4 address mapped directly to a network interface ( No NAT. No Exceptions! )
* Linux instance running Ubuntu 18.04
* Service account without sudo privileges

### Installing

Create service account

```
groupadd ipfs && useradd -d /home/ipfs -g ipfs -m -s /bin/bash ipfs
```

Enter service account

```
sudo su -l ipfs
```

Verify settings

```
curl "https://raw.githubusercontent.com/Telos-Foundation/tipfs/master/install.sh" | bash /dev/stdin --dry-run
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

Example: `--prefix /srv/ipfs`

### `--bin-prefix`

Set the install path for service specific binaries.  By default, the bin-prefix is set to `$HOME/bin`.

Example: `--bin-prefix /srv/ipfs/bin`

### `--log-prefix`

Set the path for log files.  By default, the log-prefix is set to `$HOME/log`.

Example: `--log-prefix /srv/ipfs/log`

### `--go-prefix`

Set the path for Go lang install.  By default, the go-prefix is set to `$HOME/go`.

Example: `--go-prefix /srv/ipfs/go`

### `--tmp-prefix`

Set the path for temp files.  By default, the tmp-prefix is set to `/tmp`.

Example: `--log-prefix /srv/ipfs/log`

### `--ipfs-port`

Set the port that IPFS daemon uses to communicate with the swarm.  By default, this is 4001

Example: `--ipfs-port 4001`
ipfs
### `--ipfs-api-port`

Set the port that IPFS daemon uses as an API endpoint.  By default, this is 5001 on localhost.

Example: `--ipfs-api-port 5001`

### `--ipfs-gateway-port`

Set the port that IPFS daemon uses as a webgui endpoint.  By default, this is 8080 on localhost.

Example: `--ipfs-gateway-port 8080`

### `--dns-endpoint`

Set the DNS endpoint used to kickstart TIPFS. By default this is `ipfs.telosfoundation.io`.

Example: `--ipfs-gateway-port ipfs.telosfoundation.io`

### `--network`

Set the the network that TIPFS is going to kickstart.  By default, this is `test` as in `testnet`.

Example: `--network test`

### `--bootstrap-endpoint`

Set the hostname endpoint for the bootstrap kickstart information.  By default, this is `boot` which expands to `boot.test.ipfs.telosfoundation.io`

Example: `--bootstrap-endpoint boot`

### `--swarmkey-endpoint`

Set the hostname endpoint for the swarm key kickstart information.  By default, this is `key` which expands to `key.test.ipfs.telosfoundation.io`

Example: `--swarmkey-endpoint key`

### `--ipfsv-endpoint`

Set the hostname endpoint for the ipfs version kickstart information.  By default, this is `ipfsv` which expands to `ipfsv.test.ipfs.telosfoundation.io`

Example: `--ipfsv-endpoint ipfsv`

### `--golangv-endpoint`

Set the hostname endpoint for the Go language version kickstart information.  By default, this is `golangv` which expands to `golangv.test.ipfs.telosfoundation.io`

Example: `--golangv-endpoint golangv`

## Development

### Basic theory

Todo

## Authors

* **Stephanie Sunshine** - [StephanieSunshine](https://github.com/StephanieSunshine)
* **John Hauge** - [JohnHauge](https://github.com/jhexperiment)
* **Lee Hundley** - [LeeHundley](https://github.com/initpnw)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
