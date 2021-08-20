import './ERC721Enumerable.sol';
import './Ownable.sol';
import './interfaces/IERC721.sol';
// File: contracts/KEDU.sol

import "hardhat/console.sol";

pragma solidity ^0.8.6;

contract KEDU is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //Counters used to track # of elements in a mapping
    
    // Mapping used to track each KeplerMultiVisa token's possible Kedu mint amount remaining, each KeplerMultiVisa token entitles holder to mint 3 KEDU
    mapping(uint256 => uint256) private mintAmtRemaining;

    // No need to call the contract for factually immutable values
    uint256 public constant MULTIVISA_TOTAL_SUPPLY = 399;
    uint256 public constant MINT_PER_MULTIVISA = 3;

    bool public isActive = false;
    bool public isEarlyAccess = false;
    uint256 public itemPrice;
    
    uint256 public _reserved = 277; // for giveaway
    string private baseURI;
    address public pass;

    // withdraw addresses
    address withdraw = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    
    //KEDU
    constructor (address _pass) ERC721("Kepler's Civil Society", "KEDU"){
        baseURI = "";   // URL to web server hosting image files
        itemPrice = 40000000000000000; // 0.04 ETH
        pass = _pass;
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

    function mintWithPass(uint _tokenID, uint _numMints) public payable {
        require(IERC721(pass).ownerOf(_tokenID) == msg.sender,                  "You do not own the Multivisa with specified ID");
        require(mintAmtRemaining[_tokenID] + _numMints <= MINT_PER_MULTIVISA,   "Multivisa of Specified Token ID Cannot Mint Requested Amount");
        require(isEarlyAccess,                                                  "Keplers Civil Society Early Access Sale Has Not Started");
        require(_tokenIds.current() + _numMints <= 4000 - _reserved,            "Minting Maxed Out");
        require(msg.value >= itemPrice * _numMints,                             "Insufficient ETH sent for Payment");
        require(_numMints <= 3,                                                 "Maximum 3 Mints Per Transaction");
        require(_numMints > 0,                                                  "Youre Welcome");

        mintAmtRemaining[_tokenID] += _numMints;

        for(uint i = 0; i < _numMints; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            _tokenIds.increment();
        }
    }
    
    function mint(uint numberOfMints) public payable {
        require(isActive,                                                   "Keplers Civil Society Sale Has Not Started");
        require(_tokenIds.current() + numberOfMints <= 7777 - _reserved,    "Minting Maxed Out");
        require(msg.value >= itemPrice * numberOfMints,                     "Insufficient ETH sent for Payment");
        require(numberOfMints <= 20,                                        "Maximum 20 Mints Per Transaction");
        require(numberOfMints > 0,                                          "Youre Welcome");
        
        for(uint i = 0; i < numberOfMints; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
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

    function setEarlyAccess(bool val) public onlyOwner {
        isEarlyAccess = val;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setItemPrice(uint256 _price) public onlyOwner {
		itemPrice = _price;
	}
    
    function giveAway(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= _reserved,   "Requested Giveaway Exceeds Giveaway Reserves");
        require(_amount > 0,            "Cant give any nothing");
        for(uint256 i; i < _amount; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(_to, newItemId);
            _tokenIds.increment();
        }
        _reserved -= _amount;
    }
     
    function getMintedCountForStardustTokenId(uint _tokenID) public view returns (uint256) {
        require(_tokenID < MULTIVISA_TOTAL_SUPPLY, "Invalid Multivisa Token ID");
        return mintAmtRemaining[_tokenID];
    }
    
    function withdrawEth() public onlyOwner {
        uint256 _each = address(this).balance;
        require(payable(withdraw).send(_each));
    }
}