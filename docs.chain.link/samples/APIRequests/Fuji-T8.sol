// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";


contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId, uint256 volume);

    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
        _setChainlinkOracle(YOUR_ORACLE_CONTRACT_ADDRESS);
        jobId = "YOUR_JOB_ID";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req._add(
            "get",
            "http://host.docker.internal:8080"
        );
        req._add("path", "0,altitude"); 

        req._add(
            "get2",
            "http://host.docker.internal:8080"
        );
        req._add("path2", "1,altitude");

        req._add(
            "get3",
            "http://host.docker.internal:8080"
        );
        req._add("path3", "2,altitude");

        req._add(
            "get4",
            "http://host.docker.internal:8080"
        );
        req._add("path4", "3,altitude");

        req._add(
            "get5",
            "http://host.docker.internal:8080"
        );
        req._add("path5", "4,altitude");

        req._add(
            "get6",
            "http://host.docker.internal:8080"
        );
        req._add("path6", "5,altitude");

        req._add(
            "get7",
            "http://host.docker.internal:8080"
        );
        req._add("path7", "6,altitude");

        req._add(
            "get8",
            "http://host.docker.internal:8080"
        );
        req._add("path8", "7,altitude");

        int256 timesAmount = 1;
        req._addInt("times", timesAmount);

        // Sends the request
        return _sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _volume
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestVolume(_requestId, _volume);
        volume = _volume;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}