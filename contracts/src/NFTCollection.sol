// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title NFTCollection
 * @dev ERC-721 NFT collection with minting, metadata, and enumeration
 */
contract NFTCollection is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 public maxSupply;
    uint256 public mintPrice;
    bool public mintingEnabled;

    mapping(uint256 => address) public tokenMinter;

    event NFTMinted(uint256 indexed tokenId, address indexed minter, string tokenURI);
    event MintPriceUpdated(uint256 newPrice);
    event MaxSupplyUpdated(uint256 newMaxSupply);
    event MintingToggled(bool enabled);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        mintingEnabled = true;
    }

    /**
     * @dev Mint new NFT with metadata URI
     * @param to Recipient address
     * @param uri Token metadata URI
     * @return tokenId Minted token ID
     */
    function mint(address to, string memory uri) public payable returns (uint256) {
        require(mintingEnabled, "Minting is disabled");
        require(totalSupply() < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        tokenMinter[tokenId] = msg.sender;

        emit NFTMinted(tokenId, msg.sender, uri);

        return tokenId;
    }

    /**
     * @dev Mint NFT for free (owner only)
     * @param to Recipient address
     * @param uri Token metadata URI
     * @return tokenId Minted token ID
     */
    function ownerMint(address to, string memory uri) public onlyOwner returns (uint256) {
        require(totalSupply() < maxSupply, "Max supply reached");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        tokenMinter[tokenId] = owner();

        emit NFTMinted(tokenId, owner(), uri);

        return tokenId;
    }

    /**
     * @dev Batch mint NFTs (owner only)
     * @param to Recipient address
     * @param uris Array of metadata URIs
     */
    function batchMint(address to, string[] memory uris) public onlyOwner {
        require(totalSupply() + uris.length <= maxSupply, "Exceeds max supply");

        for (uint256 i = 0; i < uris.length; i++) {
            ownerMint(to, uris[i]);
        }
    }

    /**
     * @dev Get all token IDs owned by address
     * @param owner Address to query
     * @return Token IDs array
     */
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokens = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokens;
    }

    /**
     * @dev Update mint price (owner only)
     * @param newPrice New mint price in wei
     */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
        emit MintPriceUpdated(newPrice);
    }

    /**
     * @dev Update max supply (owner only)
     * @param newMaxSupply New maximum supply
     */
    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply >= totalSupply(), "Cannot set below current supply");
        maxSupply = newMaxSupply;
        emit MaxSupplyUpdated(newMaxSupply);
    }

    /**
     * @dev Toggle minting on/off (owner only)
     */
    function toggleMinting() public onlyOwner {
        mintingEnabled = !mintingEnabled;
        emit MintingToggled(mintingEnabled);
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    /**
     * @dev Get remaining NFTs available to mint
     */
    function remainingSupply() public view returns (uint256) {
        return maxSupply - totalSupply();
    }

    // Required overrides

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
