import './ERC721Enumerable.sol';
import './Ownable.sol';
import './ERC20.sol';
// File: contracts/KEDU.sol

pragma solidity ^0.8.6;

contract KeplerMultivisa is ERC20 {

    constructor () ERC20("KeplerMultivisa", "VISA"){
        itemPrice = 70000000000000000; // 0.07 ETH
    }

    function mint( uint256 _item ){
        require(msg.value > itemPrice, "Insufficient Payment");
        require(_item < 10 , "Can only mint 10");
        _safeMint(msg.sender,_item);
    }

    function getItemPrice() public view returns (uint256){
		return itemPrice;
	}

}