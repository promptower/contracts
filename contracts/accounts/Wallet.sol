// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable, IERC721Receiver {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public immutable factory;

    modifier onlyFactory() {
        if (msg.sender != factory) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    receive() external payable {}

    constructor() Ownable(msg.sender /* factory */) {
        factory = msg.sender;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        tokenId;
        data;
        return IERC721Receiver.onERC721Received.selector;
    }

    /* Factory functions */

    function initialize(address newOwner_) public onlyFactory {
        _transferOwnership(newOwner_);
    }

    /* execute functions */

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external payable virtual onlyOwner returns (bytes memory result) {
        return _call(dest, value, func);
    }

    function executeBatch(
        address[] calldata dest,
        uint256[] calldata value,
        bytes[] calldata func
    ) external payable virtual onlyOwner returns (bytes[] memory results) {
        require(
            dest.length == func.length &&
                (value.length == 0 || value.length == func.length),
            "wrong array length"
        );

        results = new bytes[](func.length);

        if (value.length == 0) {
            for (uint256 i = 0; i < dest.length; ) {
                address _dest = dest[i];
                bytes calldata _func = func[i];
                bytes memory result = _call(_dest, 0, _func);
                results[i] = result;

                unchecked {
                    ++i;
                }
            }
        } else {
            for (uint256 i = 0; i < dest.length; ) {
                address _dest = dest[i];
                bytes calldata _func = func[i];
                bytes memory result = _call(_dest, value[i], _func);
                results[i] = result;

                unchecked {
                    ++i;
                }
            }
        }
    }

    function _call(
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (bytes memory result) {
        bool success;
        (success, result) = target.call{value: value}(data);
        if (!success) {
            // Next 5 lines from https://ethereum.stackexchange.com/a/83577
            if (result.length < 68) revert();
            assembly {
                result := add(result, 0x04)
            }
            revert(abi.decode(result, (string)));
        }
    }
}
