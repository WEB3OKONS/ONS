# ONS
1、ons resolver

import { default as namehash } from 'eth-ens-namehash';

1.1 Resolve domain hash

//all tldindex

//tldindex  ok:0 okt:1 okc:2 okx:3


//Hansen.okx

//name:Hansen

//tldindex:3

//tld:okx

let name = "Hansen"+"-"+3+"."+"okx" //Hansen-3.okx
//Convert to lowercase

let domainhash = namehash.hash(name.toLocaleLowerCase());

//0xef5e6d830730d19bf3aedc4d2e2312f9518e980de87a70ca2a96879240262039

1.2 Get domain resolver contract address

//ons address 0xed5064c540e62c888a3132535607bf5a89043B04

//Call the ons method to get the resolver


{
  "constant": true,
  "inputs": [
    {
      "internalType": "bytes32",
      "name": "node",
      "type": "bytes32"
    }
  ],
  "name": "resolver",
  "outputs": [
    {
      "internalType": "address",
      "name": "",
      "type": "address"
    }
  ],
  "payable": false,
  "stateMutability": "view",
  "type": "function"
}        

let resolver =  await this.ons.resolver(domainhash).call({gas:0});


1.3 Call the resolver contract obtained in 1.2 to resolve the domain name


publicResolverABI:
{
  "constant": true,
  "inputs": [
    {
      "internalType": "bytes32",
      "name": "node",
      "type": "bytes32"
    }
  ],
  "name": "addr",
  "outputs": [
    {
      "internalType": "address payable",
      "name": "",
      "type": "address"
    }
  ],
  "payable": false,
  "stateMutability": "view",
  "type": "function"
}
        
 let resolverContract = new web3.eth.Contract(
        publicResolverABI,
        resolver,
        {
          from: this.account,
        }
      );
      
resolverContract.methods.addr(domainhash).call({gas:0})
      .then((result) => {
          let okAddress = result;
      }).catch((err) => {
	        });

