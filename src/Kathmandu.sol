// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {WrapToken} from "./WrapToken.sol";

contract Kathmandu {
    // event Unstake(
    //     address from,
    //     uint256 s0,
    //     uint256 s,
    //     uint256 deposited,
    //     uint256 reward,
    //     uint256 t
    // );
    // event LPFeeDistribution(
    //     address from,
    //     uint256 lpRewards,
    //     uint256 t,
    //     uint256 s,
    //     uint256 feeRateToLPsIn100
    // );

    address owner;

    struct Durbar {
        address baseToken;
        address wrapToken;
        address liqToken;
        uint256 balanceBaseToken;
        uint256 mintedWrap;
        uint256 feeRateToWrappers100;
        uint256 feeRateToLPsIn100;
        uint256 feeRateToDevIn100;
        bool exists;
        //staked LP fee-dist
        uint256 t;
        uint256 s;
        //only accumulative stats
        uint256 accumulatedLPfees;
        uint256 accumulatedDevfees;
        uint256 accumulatedWrapperfees;
        uint256 durbarCreatedAt;
    }

    mapping(string => Durbar) public supportedDurbars;

    //staked LP fee-dist
    mapping(string => mapping(address => uint256)) stakedLiqTokenBalances;
    mapping(string => mapping(address => uint256)) s0;

    constructor() {
        owner = msg.sender;
    }

    function addDurbar(
        string memory durbarName,
        address baseToken,
        address wrapToken,
        address liqToken,
        uint256 feeRateToWrappers100,
        uint256 feeRateToLPsIn100,
        uint256 feeRateToDevIn100
    ) public {
        //require(msg.sender == owner);
        //require(supportedDurbars[durbarName].exists != true, "Durbar exists already.");

        Durbar memory newDurbar = Durbar(
            baseToken,
            wrapToken,
            liqToken,
            0,
            0,
            feeRateToWrappers100,
            feeRateToLPsIn100,
            feeRateToDevIn100,
            true,
            0,
            0,
            0,
            0,
            0,
            block.timestamp
        );
        supportedDurbars[durbarName] = newDurbar;
    }

    function calculateFees(uint256 amount, string memory durbarName) internal returns (uint256[3] memory) {
        uint256 wrapperReward = Math.mulDiv(amount, supportedDurbars[durbarName].feeRateToWrappers100 / 2, 10000);

        uint256 lpReward = Math.mulDiv(amount, supportedDurbars[durbarName].feeRateToLPsIn100 / 2, 10000);
        uint256 devReward = Math.mulDiv(amount, supportedDurbars[durbarName].feeRateToDevIn100 / 2, 10000);

        supportedDurbars[durbarName].accumulatedDevfees = supportedDurbars[durbarName].accumulatedDevfees + devReward;
        supportedDurbars[durbarName].accumulatedWrapperfees =
            supportedDurbars[durbarName].accumulatedWrapperfees + wrapperReward;

        uint256[3] memory res = [wrapperReward, lpReward, devReward];
        return res;
    }

    function distributeLPrewards(uint256 lpReward, string memory durbarName) internal returns (bool) {
        if (supportedDurbars[durbarName].t == 0) {
            return false;
        } else {
            supportedDurbars[durbarName].s =
                supportedDurbars[durbarName].s + (lpReward * 10 ** 18 / supportedDurbars[durbarName].t);
        }

        return true;

        // emit LPFeeDistribution(
        //     msg.sender,
        //     lpReward,
        //     supportedDurbars[durbarName].t,
        //     supportedDurbars[durbarName].s,
        //     supportedDurbars[durbarName].feeRateToLPsIn100
        // );
    }

    function wrapDurbar(string memory durbarName, uint256 amount) public {
        require(supportedDurbars[durbarName].exists, "Durbar does not exist.");
        ERC20 tokenToWrap = ERC20(supportedDurbars[durbarName].baseToken);
        tokenToWrap.transferFrom(msg.sender, address(this), amount);

        uint256[3] memory fees = calculateFees(amount, durbarName);

        //Calculate fees
        uint256 wrapperReward = fees[0];
        uint256 lpReward = fees[1];
        uint256 devReward = fees[2];

        bool lpDistributed = distributeLPrewards(lpReward, durbarName);

        if (!lpDistributed) {
            lpReward = 0;
        } else {
            supportedDurbars[durbarName].accumulatedLPfees = supportedDurbars[durbarName].accumulatedLPfees + lpReward;
        }

        uint256 amountWithFees = amount - (wrapperReward + lpReward + devReward);

        uint256 wrapTokenAmount;
        if (supportedDurbars[durbarName].mintedWrap == 0) {
            wrapTokenAmount = amountWithFees;
        } else {
            wrapTokenAmount = Math.mulDiv(
                amountWithFees, supportedDurbars[durbarName].mintedWrap, supportedDurbars[durbarName].balanceBaseToken
            );
        }

        supportedDurbars[durbarName].mintedWrap = supportedDurbars[durbarName].mintedWrap + wrapTokenAmount;

        supportedDurbars[durbarName].balanceBaseToken =
            supportedDurbars[durbarName].balanceBaseToken + (amountWithFees + wrapperReward);

        WrapToken wrapToken = WrapToken(supportedDurbars[durbarName].wrapToken);
        wrapToken.mint(msg.sender, wrapTokenAmount);
    }

    function unwrapDurbar(string memory durbarName, uint256 amount) public {
        require(supportedDurbars[durbarName].exists, "Durbar does not exist.");

        //Burn wrapped token
        WrapToken wrapToken = WrapToken(supportedDurbars[durbarName].wrapToken);
        wrapToken.burnFrom(msg.sender, amount);

        //Calculate share
        uint256 tokenBackWithoutFees =
            Math.mulDiv(amount, supportedDurbars[durbarName].balanceBaseToken, supportedDurbars[durbarName].mintedWrap);

        uint256[3] memory fees = calculateFees(tokenBackWithoutFees, durbarName);

        //Calculate fees
        uint256 wrapperReward = fees[0];
        uint256 lpReward = fees[1];
        uint256 devReward = fees[2];

        supportedDurbars[durbarName].accumulatedLPfees = supportedDurbars[durbarName].accumulatedLPfees + lpReward;

        supportedDurbars[durbarName].balanceBaseToken =
            supportedDurbars[durbarName].balanceBaseToken - (tokenBackWithoutFees - wrapperReward);

        supportedDurbars[durbarName].mintedWrap = supportedDurbars[durbarName].mintedWrap - amount;

        //LP fee distribution
        distributeLPrewards(lpReward, durbarName);

        //send back baseToken

        uint256 tokenBackWithFees = tokenBackWithoutFees - (wrapperReward + lpReward + devReward);
        ERC20 baseToken = ERC20(supportedDurbars[durbarName].baseToken);
        baseToken.transfer(msg.sender, tokenBackWithFees);
    }

    function stakeLiq(string memory durbarName, uint256 amount) public {
        require(supportedDurbars[durbarName].exists, "Durbar does not exist.");
        require(s0[durbarName][msg.sender] == 0, "Needs unstake before restake (s0)");
        require(
            stakedLiqTokenBalances[durbarName][msg.sender] == 0, "Needs unstake before restake (stakedLiqTokenBalances)"
        );

        ERC20 liqToken = ERC20(supportedDurbars[durbarName].liqToken);
        liqToken.transferFrom(msg.sender, address(this), amount);

        stakedLiqTokenBalances[durbarName][msg.sender] = amount;
        s0[durbarName][msg.sender] = supportedDurbars[durbarName].s;

        supportedDurbars[durbarName].t = supportedDurbars[durbarName].t + amount;
    }

    function unStakeLiq(string memory durbarName, uint256 amount) public {
        require(supportedDurbars[durbarName].exists, "Durbar does not exist.");
        require(stakedLiqTokenBalances[durbarName][msg.sender] > 0, "Nothing staked.");

        uint256 deposited = stakedLiqTokenBalances[durbarName][msg.sender];
        require(amount == deposited, "Can only unstake all.");

        uint256 reward = (deposited * (supportedDurbars[durbarName].s - s0[durbarName][msg.sender])) / 10 ** 18;

        // emit Unstake(
        //     msg.sender,
        //     s0[durbarName][msg.sender],
        //     supportedDurbars[durbarName].s,
        //     deposited,
        //     reward,
        //     supportedDurbars[durbarName].t
        // );

        supportedDurbars[durbarName].t = supportedDurbars[durbarName].t - deposited;

        stakedLiqTokenBalances[durbarName][msg.sender] = 0;

        s0[durbarName][msg.sender] = 0;

        //Send reward:

        ERC20 baseToken = ERC20(supportedDurbars[durbarName].baseToken);
        baseToken.transfer(msg.sender, reward);

        //Send back liq token:

        ERC20 liqToken = ERC20(supportedDurbars[durbarName].liqToken);
        liqToken.transfer(msg.sender, deposited);
    }

    function getTVLforDurbars(string[] memory durbarNames) public view returns (uint256[][] memory) {
        uint256[][] memory durbarWrapBalances;
        for (uint256 i = 0; i < durbarNames.length; i++) {
            string memory durbarName = durbarNames[i];
            durbarWrapBalances[i][0] = supportedDurbars[durbarName].balanceBaseToken;
            durbarWrapBalances[i][1] = supportedDurbars[durbarName].t;
        }
        return durbarWrapBalances;
    }

    function getWrapTokenRatioForDurbar(string memory durbarName) public view returns (uint256) {

        if(supportedDurbars[durbarName].mintedWrap == 0 || supportedDurbars[durbarName].balanceBaseToken == 0){
            return  1 * 10 ** 18;
        }
        uint256 amount = Math.mulDiv(
            1 * 10 ** 18, supportedDurbars[durbarName].mintedWrap, supportedDurbars[durbarName].balanceBaseToken
        );
        return amount;
    }

    function getTotalLPrewardsAndStakedLPAmountForDurbar(string memory durbarName) public view returns (uint256[2] memory) {
        return [supportedDurbars[durbarName].accumulatedLPfees,supportedDurbars[durbarName].t];
    }

    function getCreationTimeForDurbar(string memory durbarName) public view returns (uint256) {
        return supportedDurbars[durbarName].durbarCreatedAt;
    }

    function getStakedLPandRewardInfoForUser(string memory durbarName, address user)
        public
        view
        returns (uint256[2] memory)
    {
        uint256 deposited = stakedLiqTokenBalances[durbarName][user];
        uint256 reward = (deposited * (supportedDurbars[durbarName].s - s0[durbarName][user])) / 10 ** 18;
        uint256[2] memory toreturn = [deposited, reward];
        return toreturn;
    }

    function getAssociatedTokensForDurbar(string memory durbarName) public view returns (address[3] memory) {
        return [
            supportedDurbars[durbarName].baseToken,
            supportedDurbars[durbarName].wrapToken,
            supportedDurbars[durbarName].liqToken
        ];
    }

    function getFeesForDurbar(string memory durbarName) public view returns (uint256[3] memory) {
        return [
            supportedDurbars[durbarName].feeRateToWrappers100,
            supportedDurbars[durbarName].feeRateToLPsIn100,
            supportedDurbars[durbarName].feeRateToDevIn100
        ];
    }
}
