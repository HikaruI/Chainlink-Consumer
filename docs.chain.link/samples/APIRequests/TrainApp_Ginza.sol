// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DelayNFT is ChainlinkClient, ConfirmedOwner, ERC721URIStorage {
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;
    uint256 private tokenIdCounter;

    // 固定されたIPFSのメタデータURI
    string private constant METADATA_URI = "https://ipfs.io/ipfs/QmZ5APXMTve67UNGKwWYNu9TiwUSX1Acnz4ZBrj6B9jMJq?filename=ginza_delay_metadata.json";

    event RequestVolume(bytes32 indexed requestId, uint256 volume);
    event NFTIssued(address indexed to, uint256 tokenId);

    constructor() ConfirmedOwner(msg.sender) ERC721("GinzaLineDelayCertificate", "DCERT") {
        _setChainlinkToken(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846); // Avalanche Fuji LINKトークン
        _setChainlinkOracle(0x66ea90738F17Ada0c5C9bC2E8C0189Bd3C058C79); // Chainlink Oracle
        jobId = "5ed22ce8b19f4658b2a26af1692495e1";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0.1 LINK
        tokenIdCounter = 0;
    }

    function requestDelayInfo() public returns (bytes32 requestId) {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req._add("get", "http://host.docker.internal:3000/modified-train-info");
        req._add("path", "0,odpt:trainInformationText"); 
        return _sendChainlinkRequest(req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _volume)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestVolume(_requestId, _volume);
        volume = _volume;

        // 遅延がある場合にMetaMaskアドレスにNFTを発行
        if (_volume == 0) {
            issueNFT(0x6AB4792BC7F2eE375652E6e156649F2F73b18A21); // MetaMaskアドレス
        }
    }

    function issueNFT(address recipient) internal {
        uint256 newTokenId = tokenIdCounter;
        _mint(recipient, newTokenId);

        // 固定されたIPFSメタデータURIを設定
        _setTokenURI(newTokenId, METADATA_URI);

        emit NFTIssued(recipient, newTokenId);
        tokenIdCounter += 1;
    }
}
