// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ZahoorKhan is ERC721, Ownable, Pausable, ERC721URIStorage {

    uint256 public totalMintingLimit;
    uint256 public totalMinted;
    uint256 public mintingLimitPerUser;
    uint256 public whitelistUserMintingLimit;
    uint256 public publicMintingLimit;
    uint256 public platformMintingLimit;
    string public baseURI;

    bool public publicSalesStatus;
    bool public mintingStatus;

    struct nftInfo {
        string metadataHash;
    }
    mapping(address => bool) public whitelistUser;
    mapping(address => uint256) public nftMintedPerUser;
    mapping(address => bool) public platformUsers;
    mapping(uint256 => nftInfo) public NFTs;

    // Custom errors
    error minting_status_inactive();
    error total_minting_limit_reached();
    error minting_limit_per_user_reached(address addr);
    error whitelist_minting_limit_reached(address addr);
    error platform_minting_limit_reached(address addr);
    error public_minting_limit_reached(address addr);
    error already_a_user(address addr);
    error public_sale_inactive();
    error public_sale_actived();

    event nft_minted(
        address indexed minter,
        uint256 tokenId,
        string metaDataHash
    );
        event recieveEth(address sender, uint value, bytes data);

    event baseURIupdated(address by, string newURI);
    event added_to_whitelist(address addr);
    event added_to_platform(address addr);
    event removed_from_platform(address addr);
    event public_sale_activated();
    event contract_paused();
    event contract_unpaused();
    event minting_status_activated();
    event minting_status_deactivated();

    constructor(
        uint256 _totalMintingLimit,
        uint256 _whiteListMintingLimit,
        uint256 _platformMintingLimit,
        uint256 _mintingLimitPerUser,
        string memory _baseURI
    ) ERC721("ZahoorKhan_Token", "ZKT") {
        require(
            _totalMintingLimit >=
                _whiteListMintingLimit + _platformMintingLimit,
            "Whitelist and Platform Minting limit exceed Total Minting Limit"
        );
        totalMintingLimit = _totalMintingLimit;
        whitelistUserMintingLimit = _whiteListMintingLimit;
        publicMintingLimit =
            _totalMintingLimit -
            (_whiteListMintingLimit + _platformMintingLimit);
        platformMintingLimit = _platformMintingLimit;
        mintingLimitPerUser = _mintingLimitPerUser;
        baseURI = _baseURI;
    }

    modifier onlyWhiteListedAdmins() {
        require(
            platformUsers[msg.sender],
            "You are not in the whitelistAdmins List"
        );
        _;
    }
    modifier onlyWhitelistedUser() {
        require(
            whitelistUser[msg.sender],
            "You are not in the whitelistAdmins List"
        );
        _;
    }

    /**
     *
     *@param _user it is the address that is to be added to whiteList
     *
     *@dev This function add addresses to WhiteList User mapping and it can only
     *
     * called by the Contract Owner
     *
     */

    function addToWhiteList(address _user) public onlyOwner whenNotPaused {
        if (platformUsers[_user]) {
            revert already_a_user(_user);
        }
        whitelistUser[_user] = true;
        emit added_to_whitelist(_user);
    }

    /**
     *
     *@dev This function will activate the Public Minting ,add the whitelistUeser
     *
     * remaining minting limit to Public Miniting Limit  and it can only
     *
     * called by the Contract Owner
     *
     */

    function allowPublicSales() public onlyOwner whenNotPaused {
        publicSalesStatus = true;
        publicMintingLimit += whitelistUserMintingLimit;
        whitelistUserMintingLimit = 0;
        emit public_sale_activated();
    }

    /**
     *
     *@param _user it is the address that is to be added to Platform List
     *
     *@dev This function add addresses to platform User mapping, check that if
     *
     *  it is not already a whitelist User and it can only
     *
     * called by the Contract Owner
     *
     */

    function addToPlatform(address _user) public onlyOwner whenNotPaused {
        if (whitelistUser[_user]) {
            revert already_a_user(_user);
        }
        platformUsers[_user] = true;
        emit added_to_platform(_user);
    }

    /**
     *
     *@param _user it is the address that is to be remove form platform list
     *
     *@dev This function remove addresses from platform User mapping and it can only
     *
     * called by the Contract Owner
     *
     */

    function removeFromPlatform(address _user) public onlyOwner whenNotPaused {
        platformUsers[_user] = false;
        emit removed_from_platform(_user);
    }

    /**
     *
     *@dev This function Paused the Contract and it can only
     *
     * called by the Contract Owner
     *
     */

    function pausedContract() public onlyOwner {
        _pause();
        emit contract_paused();
    }

    /**
     *
     *@dev This function unPaused the Contract and it can only
     *
     *     called by the Contract Owner
     *
     */

    function unPausedContract() public onlyOwner {
        _unpause();
        emit contract_unpaused();
    }

    /**
     *
     *@param _baseURI it is the base URI where all the NFTs data are stored
     *
     *@dev This function update the baseURI  and it can only
     *
     *     called by the Whitelisted User
     *
     */

    function updateBaseURI(string memory _baseURI)
        public
        onlyWhiteListedAdmins
        whenNotPaused
    {
        baseURI = _baseURI;
        emit baseURIupdated(msg.sender, baseURI);
    }

    /**
     *
     *@dev This function paused and unPased the minting Funtion and it can only
     *
     * called by the Contract Ownerindexed
     *
     */

    function alterMintingStatus() public onlyOwner whenNotPaused {
        if (!mintingStatus) {
            mintingStatus = true;
            emit minting_status_activated();
        } else {
            mintingStatus = false;
            emit minting_status_deactivated();
        }
    }

    /**
     *
     *@dev This function is for burning but will not work in this contract
     *
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {}

    /**
     *
     *@param tokenId it is the Id of the nft
     *
     *@dev This function return the token URI of the nfts
     *
     */

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, NFTs[tokenId].metadataHash));
    }

    /**
     *
     *@param tokenId it is the minting ID of the Nft
     *
     *@param _metadataHash this is the hash of the Json file stored in a Decentralized server
     *
     *@param _minter this is address who mint the nft
     *
     *@dev This function perform the Nft minting operation for the Minting functions
     *
     */

    function mint(
        uint256 tokenId,
        string memory _metadataHash,
        address _minter
    ) internal {
        NFTs[tokenId].metadataHash = _metadataHash;
        _safeMint(_minter, tokenId);
        _setTokenURI(tokenId, tokenURI(tokenId));
        nftMintedPerUser[_minter]++;
        totalMinted++;
        emit nft_minted(_minter, tokenId, _metadataHash);
    }

    /**
     *
     *@param tokenId it is the minting ID of the Nft
     *
     *@param _metadataHash this is the hash of the Json file stored in a Decentralized server
     *
     *@dev This function Mint the Nft as a public users it have some checks
     *
     * 1 the minting status should UnPaused
     *
     * 2 the minted Nfts should less than Minting Limit
     *
     * 3 the user minted Nfts should less than mintinglimitPerUser
     *
     *
     * saftely mint the nft ,assign the metaDataHash to the nft tokenId, decrement the total minting limit
     *
     * increment totalMinted nfts , set the token URI, increment nfts per User
     */

    function mintAsPublicUser(uint256 tokenId, string memory _metadataHash)
        public
        whenNotPaused
    {
        if (!mintingStatus) {
            revert minting_status_inactive();
        }
        if (!publicSalesStatus) {
            revert public_sale_inactive();
        }
        if (publicMintingLimit == 0) {
            revert public_minting_limit_reached(msg.sender);
        }
        if (totalMinted == totalMintingLimit) {
            revert total_minting_limit_reached();
        }

        if (nftMintedPerUser[msg.sender] == mintingLimitPerUser) {
            revert minting_limit_per_user_reached(msg.sender);
        }

        publicMintingLimit--;
        mint(tokenId, _metadataHash, msg.sender);
    }

    /**
     *
     *@param tokenId it is the minting ID of the Nft
     *
     *@param _metadataHash this is the hash of the Json file stored in a Decentralized server
     *
     *@dev This function can only call by WhitelistUser, Mint the Nft as a whiteList users it have some checks
     *
     * 1 the minting status should UnPaused
     *
     * 2 the minted Nfts should less than Minting Limit
     *
     * 3 the user minted Nfts should less than mintinglimitPerUser
     *
     *
     * saftely mint the nft ,assign the metaDataHash to the nft tokenId, decrement the total minting limit
     *
     * increment totalMinted nfts , set the token URI, increment nfts per User
     */

    function mintAsWhiteListUser(uint256 tokenId, string memory _metadataHash)
        public
        onlyWhitelistedUser
        whenNotPaused
    {
        if (publicSalesStatus) {
            revert public_sale_actived();
        }
        if (!mintingStatus) {
            revert minting_status_inactive();
        }
        if (totalMinted == totalMintingLimit) {
            revert total_minting_limit_reached();
        }

        if (nftMintedPerUser[msg.sender] == mintingLimitPerUser) {
            revert minting_limit_per_user_reached(msg.sender);
        }
        if (whitelistUserMintingLimit == 0) {
            revert whitelist_minting_limit_reached(msg.sender);
        }

        whitelistUserMintingLimit--;
        mint(tokenId, _metadataHash, msg.sender);
    }

    /**
     *
     *@param tokenId it is the minting ID of the Nft
     *
     *@param _metadataHash this is the hash of the Json file stored in a Decentralized server
     *
     *@dev This function can only call by platformUser, Mint the Nft as a whiteList users it have some checks
     *
     * 1 the minting status should UnPaused
     *
     * 2 the minted Nfts should less than Minting Limit
     *
     * 3 the user minted Nfts should less than mintinglimitPerUser
     *
     *
     * saftely mint the nft ,assign the metaDataHash to the nft tokenId, decrement the total minting limit
     *
     * increment totalMinted nfts , set the token URI, increment nfts per User
     */

    function mintAsPlatformUser(uint256 tokenId, string memory _metadataHash)
        public
        onlyWhiteListedAdmins
        whenNotPaused
    {
        if (!mintingStatus) {
            revert minting_status_inactive();
        }
        if (totalMinted == totalMintingLimit) {
            revert total_minting_limit_reached();
        }

        if (nftMintedPerUser[msg.sender] == mintingLimitPerUser) {
            revert minting_limit_per_user_reached(msg.sender);
        }

        if (platformMintingLimit == 0) {
            revert platform_minting_limit_reached(msg.sender);
        }
        platformMintingLimit--;
        mint(tokenId, _metadataHash, msg.sender);
    }





    
    /**
    * @dev  receive function to receive Ethers called when no data is sent with call
    */
    receive() external payable {
        emit recieveEth( msg.sender, msg.value, "");
    }

    /**
    * @dev fallback function to receive call with data and value.
    *
    */
    fallback() external payable {
        emit recieveEth( msg.sender, msg.value, msg.data);
    }

   
}
