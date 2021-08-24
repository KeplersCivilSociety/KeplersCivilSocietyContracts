import './ERC721Enumerable.sol';
import './Ownable.sol';
import './interfaces/IERC721.sol';
// import './Strings.sol';
// File: contracts/KEDU.sol


pragma solidity ^0.8.6;

contract KEDU is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds; //Counters used to track # of elements in a mapping
    
    // Mapping used to track each KeplerMultiVisa token's possible Kedu mint amount remaining, each KeplerMultiVisa token entitles holder to mint 3 KEDU
    mapping(uint256 => uint256) private mintAmtRemaining;


    uint256 public constant MULTIVISA_TOTAL_SUPPLY = 400;
    uint256 public constant MINT_PER_MULTIVISA = 3;

    bool public isActive = false;
    bool public isEarlyAccess = false;
    bool public mintFinalized = false;
    uint256 public itemPrice;
    
    uint256 public _reserved = 277; // for giveaway
    string private baseURI;
    address public pass;

    // Total of 100 so 10 = 10%
    uint256 ownerShare = 54;
    uint share1 = 10;
    uint share2 = 36;
    // withdraw addresses
    address share1Address = 0xb46476044e4Fe99c25c9D521F6bDc3bc98fE56C0;
    address share2Address = 0x021A440Eb6C24df41591D1C79875d8Cb66F18d57;

    
    //KEDU
    constructor (address _pass) ERC721("Keplers Civil Society", "KEDU"){
        baseURI = "";   // URL to web server hosting image files
        itemPrice = 40000000000000000; // 0.04 ETH
        pass = _pass;
        transferOwnership(address(0x5c8FC210f2ccEC69e0a78A0Ce675fcDd39BF6ba8));
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
        require(!mintFinalized,                                                 "Minting finalized.");
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
        require(!mintFinalized,                                             "Minting finalized.");
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }
    
    function setActive(bool val) public onlyOwner {
        isActive = val;
    }

    function endMint() public onlyOwner {
        mintFinalized = true;
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
     
    function getMintedCountForMultiVisaId(uint _tokenID) public view returns (uint256) {
        require(_tokenID < MULTIVISA_TOTAL_SUPPLY, "Invalid Multivisa Token ID");
        return mintAmtRemaining[_tokenID];
    }
    
    function withdrawEth() public onlyOwner {
        uint256 total = address(this).balance;
        uint256 ownerWithdraw = total*ownerShare/100;
        uint256 share1Withdraw = total*share1/100;
        uint256 share2Withdraw = total*share2/100;
        require(payable(owner()).send(ownerWithdraw));
        require(payable(share1Address).send(share1Withdraw));
        require(payable(share2Address).send(share2Withdraw));
    }
}
