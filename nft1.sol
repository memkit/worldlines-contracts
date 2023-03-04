// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.1;



contract Nft{

    bytes32 Id;

    string ipfs;

    // decodeForUser contains encryption key , encoded for given user
    mapping(address => string) decodeForUser;
    // ipfs address for the given user
    mapping(address => string) ipfsForUser; 
    mapping(address => string[]) sharedSec;


    mapping(address =>bool) owners;

    address[] encryptionChain;

    address initiator;

    mapping(address => bool) confirmed;


    mapping(address => uint) bids;
    



    function Initiate(address[] memory x)public{
        initiator = msg.sender;
        require( x[0] == msg.sender);  
        encryptionChain = x;
    }

    function Confirm(uint i)public{
        require(encryptionChain[i] == msg.sender);
        confirmed[msg.sender] = true;
    }

    function Finalize(string memory _ipfs)public{
        uint n = encryptionChain.length;
        require(msg.sender == encryptionChain[n-1]);
        ipfs = _ipfs;
    }

}


