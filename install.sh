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

# Dry run to just get info, with the optional download flag to download the
# install files locally
DRY_RUN=false
DOWNLOAD=false

DEST_PATH=$HOME

BIN_PATH=$DEST_PATH/bin
LOG_PATH=$DEST_PATH/log
GO_PATH=$DEST_PATH/golang
TMP_PATH=/tmp

# In an effort to try and keep everyone in sync on a mass level, we leverage DNS
# to hold the current variables needed in order to start a node for a specific network
# IPFS Daemon port
IPFS_PORT=4001
# IPFS API port
IPFS_API_PORT=5001
# IPFS API Loopback
IPFS_API_LOOPBACK=6001
# TIPFS Add HTTP Shim
TIPFS_ADD_SHIM=7001
# IPFS Gateway port
IPFS_GATEWAY_PORT=8080

# Network boot DNS root
DNS_ENDPOINT=ipfs.telosfoundation.io
# Network shortname [ main | test | stage | jungle | etc ]
NETWORK=stage
# boot.$NETWORK.$DNS_ENDPOINT
BOOTSTRAP_ENDPOINT=boot
# key.$NETWORK.$DNS_ENDPOINT
SWARMKEY_ENDPOINT=key
# golangv.$NETWORK.$DNS_ENDPOINT
GOLANGV_ENDPOINT=golangv
# ipfsv.$NETWORK.$DNS_ENDPOINT
IPFSV_ENDPOINT=ipfsv
# nginxv.$NETWORK.$DNS_ENDPOINT
NGINXV_ENDPOINT=nginxv
# nasxi.$NETWORK.$DNS_ENDPOINT
NAXSIV_ENDPOINT=naxsiv


OPTS=`/usr/bin/env getopt -o '' --long dry-run,download,prefix:,bin-prefix:,log-prefix:,go-prefix:,tmp-prefix:,ipfs-port:,ipfs-api-port:,ipfs-gateway-port:,dns-endpoint:,network:,bootstrap-endpoint:,swarmkey-endpoint:,ipfsv-endpoint: -n 'install' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# TODO: --nginxv-endpoint --nasxi-endpoint
while true; do
  case "$1" in
    --dry-run ) DRY_RUN=true; shift ;;
    --download ) DOWNLOAD=true; shift ;;

    --prefix ) DEST_PATH=$2; shift; shift; BIN_PATH=$DEST_PATH/bin; LOG_PATH=$DEST_PATH/log; GO_PATH=$DEST_PATH/go ;;
    --bin-prefix ) BIN_PATH=$2; shift; shift ;;
    --log-prefix ) LOG_PATH=$2; shift; shift ;;
    --go-prefix ) GO_PATH=$2; shift; shift ;;
    --tmp-prefix ) TMP_PATH=$2; shift; shift ;;

    --ipfs-port ) IPFS_PORT=$2; shift; shift ;;
    --ipfs-api-port ) IPFS_API_PORT=$2; shift; shift ;;
    --ipfs-gateway-port ) IPFS_GATEWAY_PORT=$2; shift; shift ;;
    --dns-endpoint ) DNS_ENDPOINT=$2; shift; shift ;;
    --network ) NETWORK=$2; shift; shift ;;
    --bootstrap-endpoint ) BOOTSTRAP_ENDPOINT=$2; shift; shift ;;
    --swarmkey-endpoint ) SWARMKEY_ENDPOINT=$2; shift; shift ;;
    --ipfsv-endpoint ) IPFSV_ENDPOINT=$2; shift; shift ;;
    --golangv-endpoint ) GOLANGV_ENDPOINT=$2; shift; shift ;;
    * ) break ;;
  esac
done

BOOTSTRAP=$(dig +noall +answer TXT $BOOTSTRAP_ENDPOINT.$NETWORK.$DNS_ENDPOINT |  cut -f2 -d \" )
SWARMKEY=$(dig +noall +answer TXT $SWARMKEY_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
GOLANGV=$(dig +noall +answer TXT $GOLANGV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
IPFSV=$(dig +noall +answer TXT $IPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
NGINXV=$(dig +noall +answer TXT $NGINXV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )
NAXSIV=$(dig +noall +answer TXT $NAXSIV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 -d \" | base64 -d )

printf "${NC}TIPFS Install For:${GREEN} ${NETWORK}net\n"
printf "${NC}DNS Endpoint:${GREEN} $NETWORK.$DNS_ENDPOINT\n"
printf "${NC}IPFS Bootstrap Nodes:\n${GREEN}$BOOTSTRAP\n"
printf "${NC}Swarm Key:${GREEN}\n$SWARMKEY\n"
printf "${NC}Go Lang Version:${GREEN} $GOLANGV\n"
printf "${NC}IPFS Version:${GREEN} $IPFSV\n"
printf "${NC}Nginx Version:${GREEN} $NGINXV\n"
printf "${NC}Naxsi Version:${GREEN} $NAXSIV\n"


#TIPFSV=$(dig +noall +answer TXT $TIPFSV_ENDPOINT.$NETWORK.$DNS_ENDPOINT | cut -f2 | tr -d \" | base64 -d )

GO_URL="https://dl.google.com/go/$GOLANGV"
IPFS_URL="https://dist.ipfs.io/go-ipfs/$IPFSV"
NGINX_URL="https://nginx.org/download/$NGINXV"
NAXSI_URL="https://github.com/nbs-system/naxsi/archive/$NAXSIV"

TIPFS_URL="https://github.com/Telos-Foundation/tipfs/archive/master.tar.gz"

GO_FILE=`basename $GO_URL`
IPFS_FILE=`basename $IPFS_URL`
# TIPFS_FILE=`basename $TIPFS_URL`

# Debug
if $DRY_RUN ; then
  printf "${NC}GO Lang URL:${GREEN} $GO_URL\n"
  printf "${NC}IPFS URL:${GREEN} $IPFS_URL\n"
  printf "${NC}TIPFS URL:${GREEN} $TIPFS_URL\n"
  printf "${NC}NGINX URL:${GREEN} $NGINX_URL\n"
  printf "${NC}NAXSI URL:${GREEN} $NAXSI_URL\n"

  # Exit if $DOWNLOAD isn't true
  if ! $DOWNLOAD ; then exit 1; fi
fi

printf "${NC}\nDownloading...\n"

# Setup tmp space
# if this is a dry run and download is on, don't move folders
if $DRY_RUN && $DOWNLOAD ; then
    echo '--dry-run and --download detected.  Will stop after download'
else
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
fi

echo "Saving files to:" `pwd`

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
if ! wget $NGINX_URL ; then
  echo "Cannot download Nginx"
  exit 1
fi
if ! $(wget $NAXSI_URL -O naxsi-$NAXSIV) ; then
  echo "Cannot download Naxsi"
  exit 1
fi
if $DRY_RUN ; then
  exit 1
fi

echo "Installing Go in $GO_PATH from $TMP_DIR"
mkdir -p $GO_PATH

cd $TMP_DIR
mv $GOLANGV $GO_PATH
cd $GO_PATH
tar zxf $GOLANGV
cd go
mv * ..

echo
echo "Installing go-ipfs in $BIN_PATH from $TMP_DIR"
mkdir -p $BIN_PATH
cd $TMP_DIR
tar zxf go*
cd go-ipfs
mv ipfs $BIN_PATH
cd ..
rm -rf go-ipfs*

echo
echo "Installing tipfs in $BIN_PATH from $TMP_DIR"
cd $TMP_DIR
tar zxf master.tar.gz
cd tipfs-master/bin
mv * $BIN_PATH

echo
echo "Creating log path $LOG_PATH"
mkdir -p $LOG_PATH

echo "export GOPATH=$HOME/.go" >> $HOME/.bash_aliases
echo "export PATH=$BIN_PATH:$GO_PATH/bin:\$PATH" >> $HOME/.bash_aliases
echo "export LIBP2P_FORCE_PNET=1" >> $HOME/.bash_aliases

export PATH=$HOME/bin:$GO_PATH/bin:$PATH

echo
echo "Installing Nginx with Naxsi"
cd $TMP_DIR
tar zxf $NGINXV
tar zxf naxsi-$NAXSIV
cd $(echo $NGINXV | sed -e 's/\.tar\.gz$//')

./configure --with-compat --add-dynamic-module=../$(echo naxsi-$NAXSIV | sed -e 's/\.tar\.gz$//')/naxsi_src/ \
                          --sbin-path=$BIN_PATH/nginx \
                          --http-client-body-temp-path=$HOME/tmp/nginx/body \
                          --http-fastcgi-temp-path=$HOME/tmp/nginx/fastcgi \
                          --http-proxy-temp-path=$HOME/tmp/nginx/proxy \
                          --conf-path=$HOME/.nginx/nginx.conf \
                          --http-log-path=$LOG_PATH/nginx-access.log \
                          --error-log-path=$LOG_PATH/nginx-error.log \
                          --lock-path=$LOG_PATH/nginx.lock \
                          --pid-path=$LOG_PATH/nginx.pid \
                          --prefix=$HOME/nginx \
                          --with-threads \
                          --without-mail_pop3_module \
                          --without-mail_smtp_module \
                          --without-mail_imap_module \
                          --without-http_uwsgi_module \
                          --without-http_scgi_module
make
make install

cd $HOME/.nginx
wget https://raw.githubusercontent.com/Telos-Foundation/tipfs/master/conf/ipfs.rules -O nginx.conf
wget https://raw.githubusercontent.com/Telos-Foundation/tipfs/master/conf/ipfs.rules -O ipfs.rules


cd $HOME

echo "Initializing IPFS"
ipfs init
ipfs bootstrap rm --all
echo $BOOTSTRAP | xargs -n 1 ipfs bootstrap add
cd $HOME/.ipfs
printf "$SWARMKEY" > swarm.key
cd $HOME
set -x
ipfs config --json Addresses.Swarm "[\"/ip4/0.0.0.0/tcp/$IPFS_PORT\"]"
ipfs config --json Addresses.API "\"/ip4/127.0.0.1/tcp/$IPFS_API_PORT\""
ipfs config --json Addresses.Gateway "\"/ip4/127.0.0.1/tcp/$IPFS_GATEWAY_PORT\""


rm -rf $TMP_DIR

exit 1




# forget all this for now
pkill -9 ipfs

ipfs repo fsck
ipfs daemon --enable-pubsub-experiment &> ipfs.log &
ipfs pin ls | cut -f1 -d" " | xargs -n 1 ipfs pin rm
cat ipfs.log
#set +x
#echo "Installing Crontab"
#cd $TMP_DIR
#crontab -l > mycron
#echo "@reboot $HOME/bin/tipfs-watcher-cycle" >> mycron
#crontab mycron

#echo "Starting TIPFS Watchers"
#cd $HOME
#cd bin
#./tipfs-watcher-cycle
