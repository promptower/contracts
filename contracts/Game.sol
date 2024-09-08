// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {Wallet} from "./accounts/Wallet.sol";
import {Minimal6551} from "./minimal6551/Minimal6551.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

struct Metadata {
    bytes32 prompt;
    bytes32 secret;
    uint128 start;
    uint128 end;
    address winner;
}

contract Game is Minimal6551, OwnableUpgradeable {
    using Strings for uint256;
    using Strings for address;

    address public awardToken;
    mapping(uint256 tokenId => Metadata) public metas;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() Minimal6551() {
        _disableInitializers();
    }

    function initialize(
        address initialOwner_,
        address awardToken_
    ) external initializer {
        __ERC721_init_unchained("Capture-the-Prompt Game", "CTP");
        __ERC721Enumerable_init_unchained();
        __Minimal6551_init_unchained();
        __Ownable_init_unchained(initialOwner_);
        __Game_init_unchained(awardToken_);
    }

    function __Game_init(address awardToken_) internal onlyInitializing {
        __Game_init_unchained(awardToken_);
    }

    function __Game_init_unchained(
        address awardToken_
    ) internal onlyInitializing {
        awardToken = awardToken_;
    }

    /* Functions */

    function mint(address to) external pure override returns (uint256 tokenId) {
        to;
        tokenId;
        revert("Disabled.");
    }

    function mint(
        address to,
        Metadata memory metadata,
        uint256 awards
    ) external returns (uint256 tokenId) {
        /* mint */
        address walletAddress = (address(createAccount(to)));
        tokenId = uint256(uint160(walletAddress));
        _mint(to, tokenId);

        /* metadata */
        metas[tokenId] = Metadata({
            prompt: metadata.prompt,
            secret: metadata.secret,
            start: metadata.start,
            end: metadata.end,
            winner: address(0)
        });

        /* awards */
        IERC20(awardToken).transferFrom(msg.sender, walletAddress, awards);
    }

    /* Token URI */

    function _baseURI() internal pure override returns (string memory) {
        return ""; // TODO
    }

    // solhint-disable max-line-length
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);

        Metadata memory meta = metas[tokenId];

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{',
                                    '"name": "', name(), ' #', tokenId.toString(), '", ',
                                    '"description": "', 'Capture-the-Prompt Game.', '", ',
                                    '"image": "', _baseURI(), tokenId.toString(), '.png', '", ',
                                    '"attributes": [',
                                    '{"trait_type": "Prompt", "value": "', uint256(meta.prompt).toHexString(32), '"},',
                                    '{"trait_type": "Secret", "value": "', uint256(meta.secret).toHexString(32), '"},',
                                    '{"display_type": "date", "trait_type": "Start date", "value": "', uint256(meta.start).toString(), '"},',
                                    '{"display_type": "date", "trait_type": "End date", "value": "', uint256(meta.end).toString(), '"},',
                                    '{"trait_type": "Winner address", "value": "', meta.winner.toHexString(), '"}',
                                    ']',
                                    '}'
                                )
                            )
                        )
                    )
                )
            );
    }

    // solhint-enable max-line-length

    function solved(uint256 tokenId, address winner) external onlyOwner {
        Metadata storage meta = metas[tokenId];

        require(uint256(meta.start) <= block.timestamp, "Not yet.");
        require(uint256(meta.end) >= block.timestamp, "Outdated.");
        require(meta.winner == address(0), "Already solved.");

        meta.winner = winner;
        Wallet(payable(address(uint160(tokenId)))).initialize(winner);
    }

    function isSolved(uint256 tokenId) external view returns (bool) {
        return metas[tokenId].winner != address(0);
    }

    function hasBadge(
        uint256 tokenId,
        address nftAddress
    ) external view returns (bool) {
        return IERC721(nftAddress).balanceOf(address(uint160(tokenId))) != 0;
    }
}
