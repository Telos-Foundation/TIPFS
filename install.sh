#!/usr/bin/env bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color


DumpVars() {
  echo "Cannot install, dump follows"
  echo
  echo "DEST_PATH=$DEST_PATH"
  echo "BIN_PATH=$BIN_PATH"
  echo
  echo "GO_PATH=$GO_PATH"
  echo "TMP_PATH=$TMP_PATH"
  echo
  echo "GO_URL=$GO_URL"
  echo "IPFS_URL=$IPFS_URL"
  echo "TIPFS_URL=$TIPFS_URL"
  echo
  echo "GO_FILE=$GO_FILE"
  echo "IPFS_FILE=$IPFS_FILE"
  echo
  echo "IPFS_PORT=$IPFS_PORT"
  echo "DNS_ENDPOINT=$DNS_ENDPOINT"
  echo "NETWORK=$NETWORK"
  echo "GLOBAL=$GLOBAL"
  echo "BOOTSTRAP_ENDPOINT=$BOOTSTRAP_ENDPOINT"
  echo "SWARMKEY_ENDPOINT=$SWARMKEY_ENDPOINT"
  echo "IPFSV_ENDPOINT=$IPFSV_ENDPOINT"
  echo
  echo "BOOTSTRAP=$BOOTSTRAP"
  echo "SWARMKEY=$SWARMKEY"
  echo "IPFSV=$IPFSV"
  echo "GOLANGV=$GOLANGV"
  exit 1
}

# Default install paths
DEST_PATH=~
BIN_PATH=$DEST_PATH/bin
LOG_PATH=$DEST_PATH/log
GO_PATH=$DEST_PATH/go
TMP_PATH=/tmp

# In an effort to try and keep everyone in sync on a mass level, we leverage DNS
# to hold the current variables needed in order to start a node for a specific network
# IPFS Daemon port
IPFS_PORT=4001
# Network boot DNS root
DNS_ENDPOINT=ipfs.telosfoundation.io
# Network shortname [ main | test | stage | jungle | etc ]
NETWORK=test
# boot.$NETWORK.$DNS_ENDPOINT
BOOTSTRAP_ENDPOINT=boot
# key.$NETWORK.$DNS_ENDPOINT
SWARMKEY_ENDPOINT=key
# golangv.$NETWORK.$DNS_ENDPOINT
GOLANGV_ENDPOINT=golangv
# ipfsv.$NETWORK.$DNS_ENDPOINT
IPFSV_ENDPOINT=ipfsv

# Needed for OSX to play right.

OPTS=`/usr/bin/env getopt -o '' --long prefix:,bin-prefix:,log-prefix:,go-prefix:,tmp-prefix:,ipfs-port:,dns-endpoint:,network:,bootstrap-endpoint:,swarmkey-endpoint:,ipfsv-endpoint: -n 'install' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    --prefix ) DEST_PATH=$2; shift; shift; BIN_PATH=$DEST_PATH/bin; LOG_PATH=$DEST_PATH/log; GO_PATH=$DEST_PATH/go ;;
    --bin-prefix ) BIN_PATH=$2; shift; shift ;;
    --log-prefix ) LOG_PATH=$2; shift; shift ;;
    --go-prefix ) GO_PATH=$2; shift; shift ;;
    --tmp-prefix ) TMP_PATH=$2; shift; shift ;;

    --ipfs-port ) IPFS_PORT=$2; shift; shift ;;
    --dns-endpoint ) DNS_ENDPOINT=$2; shift; shift ;;
    --network ) NETWORK=$2; shift; shift ;;
    --bootstrap-endpoint ) BOOTSTRAP_ENDPOINT=$2; shift; shift ;;
    --swarmkey-endpoint ) SWARMKEY_ENDPOINT=$2; shift; shift ;;
    --ipfsv-endpoint ) IPFSV_ENDPOINT=$2; shift; shift ;;
    * ) break ;;
  esac
done

BOOTSTRAP=$(dig +noall +answer TXT $BOOTSTRAP_ENDPOINT.$NETWORK.$DNS_ENDPOINT |  cut -f2 -d \" )
SWARMKEY=$(dig +noall +answer TXT $SWARMKEY_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
GOLANGV=$(dig +noall +answer TXT $GOLANGV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
IPFSV=$(dig +noall +answer TXT $IPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )

printf "${NC}TIPFS Install For:${GREEN} ${NETWORK}net\n"
printf "${NC}DNS Endpoint:${GREEN} $NETWORK.$DNS_ENDPOINT\n"
printf "${NC}IPFS Bootstrap:${GREEN} $BOOTSTRAP\n"
printf "${NC}Swarm Key:${GREEN}\n$SWARMKEY\n"
printf "${NC}Go Lang Version:${GREEN} $GOLANGV\n"
printf "${NC}IPFS Version:${GREEN} $IPFSV\n"
printf "${NC}\nDownloading...\n"

#TIPFSV=$(dig +noall +answer TXT $TIPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d )

GO_URL="https://dl.google.com/go/$GOLANGV"
IPFS_URL="https://dist.ipfs.io/go-ipfs/$IPFSV"
TIPFS_URL="https://github.com/Telos-Foundation/TIPFS/archive/master.tar.gz"

GO_FILE=`basename $GO_URL`
IPFS_FILE=`basename $IPFS_URL`
# TIPFS_FILE=`basename $TIPFS_URL`

# Debug
if [ "$DEBUGME" ] ; then
  DumpVars
fi

# Setup tmp space
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Download
if ! wget $GO_URL ; then
  echo "Cannot download Go"
  exit 1
fi
if ! wget $IPFS_URL ; then
  echo "Cannot download IPFS"
  exit 1
fi
if ! wget $TIPFS_URL ; then
  echo "Cannot download TIPFS"
  exit 1
fi

# Extract
echo
echo "Installing Go in $GO_PATH from $TMP_DIR"
mkdir $GO_PATH
cd $TMP_DIR
mv $GOLANGV $GO_PATH
cd $GO_PATH
tar zxvf $GOLANGV
cd go
mv * ..

echo
echo "Installing go-ipfs in $BIN_PATH from $TMP_DIR"
mkdir $BIN_PATH
cd $TMP_DIR
tar zxvf go*
cd go-ipfs
mv ipfs $BIN_PATH
cd ..
rm -rf go-ipfs*

echo
echo "Installing tipfs in $BIN_PATH from $TMP_DIR"
cd $TMP_DIR
tar zxvf master.tar.gz
cd TIPFS-master/bin
mv * $BIN_PATH

echo
echo "Creating log path $LOG_PATH"
mkdir -p $LOG_PATH

echo "export PATH=\$PATH:$GO_PATH/bin; export GOPATH=$GO_PATH" >> ~/.bash_aliases

export PATH=$PATH:$GO_PATH/bin:~/bin
cd ~

echo "Initializing IPFS"
ipfs init
ipfs bootstrap rm --all
ipfs bootstrap add $BOOTSTRAP
cd ~/.ipfs
printf "$SWARMKEY" > swarm.key
cd ~
ipfs daemon --enable-pubsub-experiment &> ipfs.log &
ipfs pin ls | cut -f1 -d" " | xargs -n 1 ipfs pin rm
cat ipfs.log

echo "Starting TIPFS Watchers"
cd ~
cd bin
./tipfs-watcher-cycle
cd $TMP_DIR
crontab -l > mycron
echo "@reboot ~/bin/tipfs-watcher-cycle" >> mycron
crontab mycron

rm -rf $TMP_DIR

