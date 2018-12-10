const Q = require('q');
const multiparty = require('multiparty');
const http = require('http');
const ipfsClient = require('ipfs-http-client');
const EosApi = require('eosjs-api');
const config = require('./config.json');

const ipfs = ipfsClient(config.ipfs.address, config.ipfs.port, { protocol: config.ipfs.protocol });

const options = {
  httpEndpoint: [config.nodeos.protocol, '://', config.nodeos.address, ':', config.nodeos.port].join(''),
  verbose: false, // API logging
  //logger: { // Default logging functions
  //  log: console.log,
  //  error: console.error
  //},
  fetchConfiguration: {}
};

const eos = EosApi(options);
const server = http.createServer(serverCb);
server.listen(config.server.port);

console.log('Server running on port', config.server.port);


function serverCb(req, res) {
  console.log("Add requested.")

  let newFileAdded = false;
  let fields, files, scope, uploadedFilePath, requestingHash, ipfsHashes, ipfsAddResult, peerInfos, replicaCount;
  Q.fcall(parseForm)
  .then(getScope)
  .then(getUploadedFile)
  .then(genHash)
  .then(getOnChainTable)
  .then(validateNewHash)
  .then(addFileToIpfs)

  .then(getSwarmPeers)
  .then(calcReplicas)
  .then(pubsubToReplicas)

  .then(respondToClient)

  .catch(errorHandler);

  return;

  function parseForm() {

    let parseFormDeferred = Q.defer();
    let form = new multiparty.Form();

    form.parse(req, parseFormCb);

    return parseFormDeferred.promise;

    function parseFormCb(err, _fields, _files) {

      fields = _fields;
      files = _files;

      if (
        ! (
          fields.scope
          && fields.scope.length
          && ( fields.scope[0] !== "" )
        )
      ) {
        fields.scope = "legacy";
      //  parseFormDeferred.reject(new Error('Missing scope.'));
      }

      if ( ! (files && files.file && files.file[0] && files.file[0].path) ) {
        parseFormDeferred.reject(new Error('Missing file.'));
      }

      parseFormDeferred.resolve();
      return;
    }

  }

  function getScope() {

    scope = fields.scope[0];

  }

  function getUploadedFile() {

    uploadedFilePath = files.file[0].path;
  }

  function genHash() {

    if ( scope === 'legacy') {
      return; // skip generating hash
    }

    let genHashDeferred = Q.defer();

    ipfs.addFromFs(uploadedFilePath, {onlyHash: true}, addFromFsCb);

    return genHashDeferred.promise;

    function addFromFsCb(error, result) {

      if (error) {
        genHashDeferred.reject(error);
        return;
      }

      requestingHash = result[0].hash;
      genHashDeferred.resolve();
      return;
    }
  }

  function getOnChainTable() {

    if ( scope === 'legacy') {
      return; // skip querying on-chain table
    }

    let getOnChainTableDeferred = Q.defer();

    eos.getTableRows({
      "json": true,
      "scope": scope,
      "code": config['ipfs.pay'].code,
      "table": config['ipfs.pay'].table
    })
    .then(parseTableRows)
    .then(getOnChainTableDeferred.resolve)
    .catch(getOnChainTableDeferred.reject);

    return getOnChainTableDeferred.promise;

    function parseTableRows(result) {

      ipfsHashes = result.rows.map((currentValue, index, arr) => {

        return currentValue.ipfs_url;
      });
    }

  }

  function validateNewHash() {

    if ( scope === 'legacy') {
      return; // skip hash validation
    }

    if ( ipfsHashes.indexOf(requestingHash) === -1 ) {

      throw new Error("File hash not authorized to add.")
    }

  }

  function addFileToIpfs() {

    let addFileToIpfsDeferred = Q.defer();

    ipfs.addFromFs(uploadedFilePath, {onlyHash: false}, addFromFsCb);

    return addFileToIpfsDeferred.promise;

    function addFromFsCb(error, result) {

      if (error) {
        addFileToIpfsDeferred.reject(error);
        return;
      }

      console.log("File added to IPFS.")

      newFileAdded = true;
      ipfsAddResult = result;
      addFileToIpfsDeferred.resolve();
      return;
    }
  }

  function getSwarmPeers() {

    let getSwarmPeers = Q.defer();

    ipfs.swarm.peers({ verbose: true }, swarmPeerCb);

    return getSwarmPeers.promise;

    function swarmPeerCb(error, _peerInfos) {

      if (error) {
        getSwarmPeers.reject(error);
        return;
      }

      peerInfos = _peerInfos;

      getSwarmPeers.resolve();
    }

  }

  function calcReplicas() {

    let peerCount = peerInfos.length;

    if ( peerCount < 4 ) {
      replicaCount = peerCount;
    }
    else if ( peerCount < 8 ) {
      replicaCount = 4;
    }
    else if ( peerCount < 13 ) {
      replicaCount = 5;
    }
    else if ( peerCount < 19 ) {
      replicaCount = 6;
    }
    else if ( peerCount < 26 ) {
      replicaCount = 7;
    }
    else if ( peerCount < 37 ) {
      replicaCount = 8;
    }
    else if ( peerCount < 51 ) {
      replicaCount = 9;
    }
    else if ( peerCount < 73 ) {
      replicaCount = 10;
    }
    else {
      replicaCount = ceil( peerCount / ( ( peerCount / 12.0 ) + 3 ) ) + 2;
    }

  }

  function pubsubToReplicas() {

    if ( ! replicaCount ) {
      console.error('No one to replicate to');
      return false;
    }

    let pubsubToReplicasDeferred = Q.defer();

    let random;
    let promises = [];
    let peerSet = peerInfos.slice(0);

    while( replicaCount-- ) {

      random = Math.floor(Math.random() * Math.floor(peerSet.length));

      promises.push(pubsub(peerSet.splice(random, 1)[0]));

    }

    Q.allSettled(promises)
    .then(pubsubToReplicasDeferred.resolve)
    .catch(pubsubToReplicasDeferred.reject);

    return pubsubToReplicasDeferred.promise;

    function pubsub(peerInfo) {

      let pubsubDeferred = Q.defer();

      const msg = Buffer.from(requestingHash);

      console.log("Asking", peerInfo.peer._idB58String, 'to pin', requestingHash);

      ipfs.pubsub.publish(peerInfo.peer._idB58String, msg, pubsubPublishCb);

      return pubsubDeferred.promise;

      function pubsubPublishCb(error) {

        if ( error ) {
          pubsubDeferred.reject(error);
          return;
        }

        pubsubDeferred.resolve();
      }
    }
  }

  function respondToClient() {
    console.log("Completed file addition and replicas notified.")

    respond({
      httpStatusCode: 200,
      httpHeaders: {'Content-type':'application/json'},
      message: JSON.stringify(ipfsAddResult)
    });
  }

  function errorHandler(error) {

    console.log(error,'\n');

    respond({
      httpStatusCode: 501,
      httpHeaders:  {'Content-type':'text/plain'},
      message: 'Invalid request.'
    });
    return null;

  }

  function respond(options) {

    res.writeHead(options.httpStatusCode, options.httpHeaders);
    res.write(options.message)
    res.end();
  }
}
