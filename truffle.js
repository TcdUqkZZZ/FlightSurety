var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "royal erode help left fantasy rack knock follow state outdoor mind uncover"


module.exports = {
  networks: {
    development: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:7545/", 0, 50);
      },
      network_id: '*',
      gas: 6721975
    }
  },
  compilers: {
    solc: {
      version: ">= 0.8.0"
    }
  }
};