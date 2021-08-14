import './ERC721Enumerable.sol';
import './Ownable.sol';
import './ERC20.sol';
// File: contracts/KEDU.sol

pragma solidity ^0.8.6;

contract KeplerMultivisa is ERC20 {

    uint256 public MAX_SUPPLY = 400;
    address public giveaway = 0x0;

    constructor () ERC20("KeplerMultivisa", "VISA"){
        itemPrice = 80000000000000000; // 0.08 ETH
        _safeMint(msg.sender,3);    //giveaway
    }

    function mint( uint256 _item ){
        require((_totalSupply+_item) < 400, "Not enough tokens left to mint requested amount.");
        require(_item < 10 , "Can only mint 10");
        require(msg.value > (itemPrice*_item), "Insufficient Payment"); //No overflow worry as max is 10 units
        _safeMint(msg.sender,_item);
        require(_totalSupply < 400, "Failed Safety Check");
    }

    function getItemPrice() public view returns (uint256){
		return itemPrice;
	}

}