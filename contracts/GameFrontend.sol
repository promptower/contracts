// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {IGame, Metadata} from "./interfaces/IGame.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

struct NftData {
    uint256 id;
    uint256 tokenId;
    string name;
    string description;
    string gameType;
    bytes32 prompt;
    bytes32 secret;
    string imageUri;
    uint128 startDate;
    uint128 endDate;
    uint256 awards;
    address winner;
}

contract GameFrontend {
    using Strings for uint256;
    using Strings for address;

    IGame public immutable gameContract;

    constructor(address gameContract_) {
        gameContract = IGame(gameContract_);
    }

    /* Token URI */

    function _baseURI() internal pure returns (string memory) {
        return
            "https://raw.githubusercontent.com/promptower/webapp/main/src/assets/nft/"; // TODO
    }

    /* Frontend Function */

    // challenge (main)
    function getNfts(
        uint256 startNumber,
        uint256 endNumber
    ) external view returns (NftData[] memory data) {
        {
            uint256 limit = IERC721Enumerable(address(gameContract))
                .totalSupply();
            if (endNumber > limit) endNumber = limit;
        }

        data = new NftData[](endNumber - startNumber);

        for (uint256 i = startNumber; i < endNumber; ) {
            uint256 tokenId = gameContract.counterToTokenId(i);
            Metadata memory meta = gameContract.metas(tokenId);

            NftData memory datum = NftData({
                id: i,
                tokenId: tokenId,
                name: meta.name,
                description: meta.description,
                gameType: meta.gameType,
                prompt: meta.prompt,
                secret: meta.secret,
                imageUri: string(
                    abi.encodePacked(_baseURI(), i.toString(), ".png")
                ),
                startDate: meta.start,
                endDate: meta.end,
                awards: IERC20(gameContract.awardToken()).balanceOf(
                    address(uint160(tokenId))
                ),
                winner: meta.winner
            });
            data[i - startNumber] = datum;

            unchecked {
                ++i;
            }
        }
    }

    // leaderboard
    function gameStatus()
        external
        view
        returns (
            uint256 totalChallanges,
            uint256 ongoingChallanges,
            uint256 solvedChallanges,
            uint256 verifiedChallanges
        )
    {
        return (
            IERC721Enumerable(address(gameContract)).totalSupply(),
            gameContract.totalOngoing(),
            gameContract.totalSolved(),
            gameContract.totalVerified()
        );
    }

    function getTopSolvers(
        uint256 topk
    )
        external
        view
        returns (
            address[] memory solvers,
            uint256[] memory counts,
            uint256[] memory awards
        )
    {
        {
            uint256 limit = gameContract.solverListLength();
            if (topk > limit) topk = limit;
        }

        solvers = new address[](topk);
        counts = new uint256[](topk);
        awards = new uint256[](topk);

        // Temporary array to store the indices of top solvers
        uint256[] memory topSolverIndices = new uint256[](topk);
        for (uint256 i = 0; i < topk; i++) {
            topSolverIndices[i] = i;
        }

        // Iterate through the remaining solvers to find the top solvers
        for (uint256 i = topk; i < gameContract.solverListLength(); i++) {
            // Find the current minimum award in the top solver list
            uint256 minIndex = 0;
            uint256 minAward = gameContract.solvedAwards(
                gameContract.solverList(topSolverIndices[minIndex])
            );

            for (uint256 j = 1; j < topk; j++) {
                if (
                    gameContract.solvedAwards(
                        gameContract.solverList(topSolverIndices[j])
                    ) < minAward
                ) {
                    minAward = gameContract.solvedAwards(
                        gameContract.solverList(topSolverIndices[j])
                    );
                    minIndex = j;
                }
            }

            // If the current solver has more awards than the minimum in the top list, replace it
            if (
                gameContract.solvedAwards(gameContract.solverList(i)) > minAward
            ) {
                topSolverIndices[minIndex] = i;
            }
        }

        for (uint256 i = 0; i < topk; i++) {
            address _solver = gameContract.solverList(topSolverIndices[i]);
            solvers[i] = _solver;
            counts[i] = gameContract.solvedCounts(_solver);
            awards[i] = gameContract.solvedAwards(_solver);
        }
    }

    // portfolio
    function getPortfolioMaker(
        address user
    ) external view returns (NftData[] memory data) {
        uint256 balance = IERC721(address(gameContract)).balanceOf(user);
        data = new NftData[](balance);

        for (uint256 index = 0; index < balance; ) {
            uint256 tokenId = IERC721Enumerable(address(gameContract))
                .tokenOfOwnerByIndex(user, index);
            uint256 i = gameContract.tokenIdToCounter(tokenId);
            Metadata memory meta = gameContract.metas(tokenId);

            NftData memory datum = NftData({
                id: i,
                tokenId: tokenId,
                name: meta.name,
                description: meta.description,
                gameType: meta.gameType,
                prompt: meta.prompt,
                secret: meta.secret,
                imageUri: string(
                    abi.encodePacked(_baseURI(), i.toString(), ".png")
                ),
                startDate: meta.start,
                endDate: meta.end,
                awards: IERC20(gameContract.awardToken()).balanceOf(
                    address(uint160(tokenId))
                ),
                winner: meta.winner
            });
            data[index] = datum;

            unchecked {
                ++index;
            }
        }
    }

    function getPortfolioSolver(
        address user
    ) external view returns (NftData[] memory data) {
        uint256[] memory solvedGamesTokenIds = gameContract.solvedGamesTokenIds(
            user
        );
        uint256 solvedGamesCount = solvedGamesTokenIds.length;
        data = new NftData[](solvedGamesCount);

        for (uint256 s = 0; s < solvedGamesCount; ) {
            uint256 tokenId = solvedGamesTokenIds[s];
            uint256 i = gameContract.tokenIdToCounter(tokenId);
            Metadata memory meta = gameContract.metas(tokenId);

            NftData memory datum = NftData({
                id: i,
                tokenId: tokenId,
                name: meta.name,
                description: meta.description,
                gameType: meta.gameType,
                prompt: meta.prompt,
                secret: meta.secret,
                imageUri: string(
                    abi.encodePacked(_baseURI(), i.toString(), ".png")
                ),
                startDate: meta.start,
                endDate: meta.end,
                awards: IERC20(gameContract.awardToken()).balanceOf(
                    address(uint160(tokenId))
                ),
                winner: meta.winner
            });
            data[s] = datum;

            unchecked {
                ++s;
            }
        }
    }
}
