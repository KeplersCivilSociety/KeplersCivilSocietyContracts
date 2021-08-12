import './ERC721Enumerable.sol';
import './Ownable.sol';
// File: contracts/KEDU.sol

pragma solidity ^0.8.6;

contract KEDU is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //Counters used to track # of elements in a mapping
    
    bool public isActive = false;
    uint256 public itemPrice;
    
    uint256 public _reserved = 127; // for giveAway
    string private baseURI;

    // withdraw addresses
    address giveaway = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    address earlyAdopter = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    address withdraw = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    
    //vegiemon dont need a lots of complicated code ╮ (. ❛ ᴗ ❛.) ╭
    constructor () ERC721("Kepler's Civil Society", "KEDU"){
        baseURI = "";   // URL to web server hosting image files
        itemPrice = 40000000000000000; // 0.05 ETH
        giveAway( giveaway, 127 ); // Giveaway wallet
        giveAway( earlyAdopter, 150 ); // Early Adopter wallet
    }

	function getItemPrice() public view returns (uint256){
		return itemPrice;
	}
	
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
    
    function mint(address player, uint numberOfMints) public payable {
        require(isActive,                                                   "Keplers Civil Society Sale Has Not Started");
        require(_tokenIds.current() + numberOfMints <= 10000 - _reserved,   "Minting Maxed Out");
        require(msg.value >= itemPrice * numberOfMints,                     "Insufficient ETH sent for Payment");
        require(numberOfMints <= 20,                                        "Maximum 20 Mints Per Transaction");
        require(numberOfMints > 0,                                          "Youre Welcome");
        
        for(uint i = 0; i < numberOfMints; i++)
        {
            uint256 newItemId = _tokenIds.current();
            _safeMint(player, newItemId);
            _tokenIds.increment();
        }
    }

    function _baseURI() internal view override returns (string memory){
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(tokenId < _tokenIds.current(), "tokenId exceeds upper bound");
        string memory _tokenURI = super.tokenURI(tokenId);
        return _tokenURI;
    }
    
    function setActive(bool val) public onlyOwner {
        isActive = val;
    }
    
    function giveAway(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= _reserved,   "exceeds reserved supply");
        require(_amount > 0,            "giveAway nothing.");
        
        for(uint256 i; i < _amount; i++)
        {
            uint256 newItemId = _tokenIds.current();
            _safeMint(_to, newItemId);
            _tokenIds.increment();
        }

        _reserved -= _amount;
    }
     
    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setItemPrice(uint256 _price) public onlyOwner {
		itemPrice = _price;
	}
    
    function withdrawEth() public onlyOwner {
        uint256 _each = address(this).balance;
        require(payable(withdraw).send(_each));
    }
}