import './ERC721Enumerable.sol';
import './Ownable.sol';
import './interfaces/IERC20.sol';
// File: contracts/KEDU.sol

pragma solidity ^0.8.6;

contract KeplerMultiVisa is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds; //Counters used to track # of elements in a mapping
    
    bool public isActive = false;
    bool public isEarlyActive = false;
    uint256 public earlyMints;
    uint256 public itemPrice;
    
    uint256 public _reserved = 3; // for giveaway
    string private baseURI;

    mapping(address => uint256) private whitelistAmount;


    // withdraw addresses
    address giveaway = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    address share1 = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    address share2 = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;
    address share3 = 0xC553E853cA924A42d5322D8Da79BA84798fA2830;

    constructor () ERC721("Kepler's Civil Society", "KEDU"){
        baseURI = "";   // URL to web server hosting image files
        itemPrice = 80000000000000000; // 0.08 ETH
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
    
    function mint(uint _numberOfMints) public payable {
        require(isActive,                                                    "Keplers Civil Society MultiVisa Sale Has Not Started");
        require(_tokenIds.current() + _numberOfMints <= 150,                 "Minting Maxed Out");
        require(msg.value >= itemPrice * _numberOfMints,                     "Insufficient ETH sent for Payment");
        require(_numberOfMints <= 10,                                        "Maximum 10 Mints Per Transaction");
        require(_numberOfMints > 0,                                          "Youre Welcome");
        
        for(uint i = 0; i < _numberOfMints; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            _tokenIds.increment();
        }
    }

    function whitelistMint() public payable {
        require(isEarlyActive,                                               "Keplers Civil Society Whitelist Mint Has Not Started");
        uint256 numMints = whitelistAmount[msg.sender];
        require(numMints > 0,                                                "Address not allowed to mint early.");

        for(uint i = 0; i < numMints; i++) {
            uint256 newItemId = 150+earlyMints; // mint starting at token ID 150
            _safeMint(msg.sender, newItemId);
            earlyMints += numMints;
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

    function setEarlyActive(bool val) public onlyOwner {
        isEarlyActive = val;
    }
    
    function giveAway() public onlyOwner {
        for(uint256 i; i < 3; i++){
            uint256 newItemId = _tokenIds.current();
            _safeMint(giveaway, newItemId);
            _tokenIds.increment();
        }
        _reserved -= 3;
    }
     
    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setItemPrice(uint256 _price) public onlyOwner {
		itemPrice = _price;
	}
    
    function withdrawEth() public onlyOwner {
        uint256 _each = address(this).balance;
        require(payable(share1).send(_each));
    }
}