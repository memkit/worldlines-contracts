// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.1;



contract Nft{

    uint N = 1000;

    string Name;

    bytes32 Id;

    string ipfs;

    address initiator;


    mapping( address => bool) owners_m;
    
    address[] owners;
    mapping( address => string) keys_m;
    string[] keys;

    mapping(address => uint) bids; 
    mapping(address => address) submitter;
    mapping(address => mapping(address => bool)) confirmed;
    mapping(address => mapping(address =>uint)) prices;
    mapping(address => bool) finalized;
    mapping(address => string) message;
    mapping(address => bool) exists;


    mapping(address => string) keys1;

    mapping(address => bool) confirmedOwn;


    function create(address[] memory x, string memory _ipfs,string[] memory _keys, string memory _Name)public{
        initiator = msg.sender;
        owners = x;
        ipfs = _ipfs;
        keys = _keys;
        uint n = x.length;
        for(uint i=0;i<n;i++){
            owners_m[x[i]] = true;
            keys_m[x[i]] = _keys[i];
        }
        Name = _Name;
    }

    function confirmOwnership()public{
        require(owners_m[msg.sender]);
        confirmedOwn[msg.sender] = true;
    }

    function GetKey(address a)public view returns(string memory){
        return keys_m[a];
    }

    function GetKey1(address a)public view returns(string memory){
        return keys1[a];
    }

    function Bid(uint x, uint[] memory y,string memory _message)public{
        require(!exists[msg.sender]);
        bids[msg.sender] = x;
        uint s;
        for(uint i=0;i<y.length;i++){
            s += y[i];
        }
        require( s== N);
        for(uint i=0;i<y.length;i++){
            prices[msg.sender][owners[i]] = y[i];
        }
        message[msg.sender] = _message;
        exists[msg.sender] = true;
       // confirmed[msg.sender] = new mapping(address => bool);
    }

    function confirm(address x)public{
        require(owners_m[msg.sender]);
        confirmed[x][msg.sender] = true;
    }

    function finalize()public payable{
        bool b = true;
        for(uint i=0;i<owners.length;i++){
            address a = owners[i];
            if(!confirmed[msg.sender][a]){
                b = false;
                break;
            }
        }
        require(b);
        require(msg.value >=bids[msg.sender]);
        for(uint i=0;i<owners.length;i++){
            address to = owners[i];
            uint val = msg.value*prices[msg.sender][to]/N;
            to.call{gas :10000, value: val}("sssssss");
        }
        finalized[msg.sender] = true;
    }


    function give(address to,string memory key)public{
        require(owners_m[msg.sender]);
        keys1[to] = key;
        submitter[to] = msg.sender;
    }

}    


