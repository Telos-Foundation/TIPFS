# telos-ipfs-validator


#### Install NodeJS
```
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install nodejs
```
#### Clone repo
```
git clone https://github.com/jhexperiment/telos-ipfs-validator.git
cd telos-ipfs-validator
npm install
```

#### Edit config.json
```
{
  "server": {
    "port": 7001
  },
  "ipfs": {
    "address": "localhost",
    "port": 6001,
    "protocol": "http"
  },
  "nodeos": {
    "address": "stage.api.telosvoyager.io",
    "port": 2888,
    "protocol": "http"
  },
  "ipfs.pay": {
    "code": "ipfspay11111",
    "table": "storage"
  }
}
```

#### Start/Restart server
```
./start.sh
```

#### Stop server
```
./stop.sh
```

#### Log
```
tail -f validator.log
```


#### ipfs.pay contract example
```
teclos set contract ipfspay11111 ../telos/contracts/ipfs.pay ipfspay.wasm ipfspay.abi -p ipfspay11111

teclos set account permission testipfs1111 active '{"threshold":1, "keys":[{"key":"EOS797uA9ifydG3Ag56aKndFVhku7QJ9EhXDytxfufHiHdtV2AS8R", "weight":1}], "accounts": [{"permission":{"actor":"ipfspay11111","permission":"eosio.code"},"weight":1}]}' owner -p testipfs1111

teclos push action ipfspay11111 buystorage '["testipfs1111"]' -p testipfs1111

teclos push action ipfspay11111 savedoc '["testipfs1111", 0, "Qmc3ugzJVGZKbZMYwPj3a9pTTcJaibrYzA4GzZ2M7TJxWk"]' -p testipfs1111

teclos get table ipfspay11111 testipfs1111 storage
```
