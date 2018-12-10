const fs = require('fs');
const IPFS = require('ipfs-api');

function ipfs(host, port, protocol) {
  return new IPFS({ 
    host: host, 
    port: port, 
    protocol: protocol
  });
};


let fileBuffer = fs.readFileSync('tmp.txt')

ipfs('localhost', 5001, 'http').add(fileBuffer, (error, ipfsHash) => {
  if (error) {
    console.log('got error in IPFS..', error)
  }
  else {
    console.log('success')
  }

})
