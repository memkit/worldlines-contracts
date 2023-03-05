// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.1;



import './fac.sol';

contract Factory is CloneFactory {
     Nft[] nfts;
     address owner;
     address master;

     constructor(){
         owner = msg.sender;
     }

    function setMaster(address a)public{
        require(msg.sender == owner);
        master = a;
    }

     function createNft(address[] memory x, string memory _ipfs,string[] memory _keys, string memory _Name, string memory _meta) external{
        Nft z = Nft(createClone(master));
        z.create(x,_ipfs,_keys,_Name,_meta);
        nfts.push(z);
     }

     function getNft(uint i) external view returns(Nft ){
         return nfts[i];
     }
}


contract Nft{

    uint N = 1000;

    string Name;

    string meta;

    bytes32 Id;

    string ipfs;

    address initiator;

    // parent NFT; 
    address parent;

    bool created;




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


    function create(address[] memory x, string memory _ipfs,string[] memory _keys, string memory _Name, string memory _meta)public{
        require(!created);
        initiator = msg.sender; //this will be factory contract
        owners = x;
        ipfs = _ipfs;
        keys = _keys;
        uint n = x.length;
        for(uint i=0;i<n;i++){
            owners_m[x[i]] = true;
            keys_m[x[i]] = _keys[i];
        }
        Name = _Name;
        meta = _meta;
        created = true;
    }

    //check that you can decrypt, before you confirm ownership!
    function confirmOwnership()public{
        require(owners_m[msg.sender]);
        confirmedOwn[msg.sender] = true;
    }

    function GetKey(address a)public view returns(string memory){
        return keys_m[a];
    }

    event GetKey1Event(address);

    function GetKey1(address a)public returns(string memory){
        emit GetKey1Event(msg.sender);
        return keys1[a];
    }

    // if your  bid does not go through, you will need to bid from different address!
    // y is the array of shares that you give to the owners; should be (500,500) for equal contribution binary conversation
    function Bid(uint x, uint[] memory y,string memory _message)public{
        require(!exists[msg.sender]);
        uint s;
        for(uint i=0;i<y.length;i++){
            s += y[i];
        }
        require( s== N);
        bids[msg.sender] = x;
        for(uint i=0;i<y.length;i++){
            prices[msg.sender][owners[i]] = y[i];
        }
        message[msg.sender] = _message;
        exists[msg.sender] = true;
    }


    event GetPriceInfoEvent(address);

    function GetPriceInfo(address a)public returns(uint[] memory){
        uint[] memory y ;
        for(uint i=0;i<owners.length;i++){
            y[i] = prices[a][owners[i]];
        }
        emit GetPriceInfoEvent(msg.sender);
        return y;
    }

    function confirm(address x)public{
        require(owners_m[msg.sender]);
        confirmed[x][msg.sender] = true;
    }

    function finalize()public payable{
        require(!finalized[msg.sender]);
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
            to.call{gas :10000, value: val}(abi.encodePacked(msg.sender));
        }
        finalized[msg.sender] = true;
    }


    function give(address to,string memory key)public{
        require(owners_m[msg.sender]);
        keys1[to] = key;
        submitter[to] = msg.sender;
    }

}    


