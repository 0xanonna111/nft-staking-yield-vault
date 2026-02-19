// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTStaking is Ownable, ReentrancyGuard {
    IERC721 public immutable nftCollection;
    IERC20 public immutable rewardToken;

    uint256 public rewardRatePerHour = 10 ether; // 10 tokens per hour

    struct Stake {
        address owner;
        uint256 tokenId;
        uint256 timestamp;
    }

    mapping(uint256 => Stake) public vault;
    mapping(address => uint256) public stakerBalances;

    event Staked(address indexed owner, uint256 tokenId, uint256 value);
    event Unstaked(address indexed owner, uint256 tokenId, uint256 value);
    event RewardClaimed(address indexed owner, uint256 reward);

    constructor(address _nftCollection, address _rewardToken) Ownable(msg.sender) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Not owner");

            nftCollection.transferFrom(msg.sender, address(this), tokenId);
            
            vault[tokenId] = Stake({
                owner: msg.sender,
                tokenId: tokenId,
                timestamp: block.timestamp
            });

            emit Staked(msg.sender, tokenId, block.timestamp);
        }
    }

    function calculateReward(uint256 tokenId) public view returns (uint256) {
        Stake memory deposited = vault[tokenId];
        uint256 stakedDuration = block.timestamp - deposited.timestamp;
        return (stakedDuration * rewardRatePerHour) / 3600;
    }

    function claim(uint256[] calldata tokenIds) external nonReentrant {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(vault[tokenId].owner == msg.sender, "Not your NFT");

            totalReward += calculateReward(tokenId);
            vault[tokenId].timestamp = block.timestamp; // Reset timer
        }
        rewardToken.transfer(msg.sender, totalReward);
        emit RewardClaimed(msg.sender, totalReward);
    }

    function unstake(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(vault[tokenId].owner == msg.sender, "Not your NFT");

            uint256 reward = calculateReward(tokenId);
            delete vault[tokenId];

            nftCollection.transferFrom(address(this), msg.sender, tokenId);
            rewardToken.transfer(msg.sender, reward);

            emit Unstaked(msg.sender, tokenId, block.timestamp);
        }
    }
}
