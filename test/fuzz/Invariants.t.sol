// SPDX-License-Identifier: MIT

// What are our invariants?

// 1. The total supply of DSC should be less than the total value of collateral

// 2. Getter view functions should never revert <- evergreen invariant
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    HelperConfig config;
    DecentralizedStableCoin dsc;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console2.log("weth value:", wethValue);
        console2.log("wbtc value:", wbtcValue);
        console2.log("total supply:", totalSupply);
        console2.log("times mint is called:", handler.timesMintIsCalled());

        // Add more specific assertions
        assert(wethValue + wbtcValue >= totalSupply);
        assert(totalWethDeposited >= 0);
        assert(totalWbtcDeposited >= 0);
    }

    function invariant_gettersShouldNotRevert() public view {
        dsce.getAccountCollateralValue(address(0));
        dsce.getAccountInformation(address(0));
        dsce.getAdditionalFeedPrecision();
        dsce.getCollateralBalanceOfUser(address(0), address(0));
        dsce.getCollateralTokenPriceFeed(address(0));
        dsce.getCollateralTokens();
        dsce.getDsc();
        dsce.getHealthFactor(address(0));
        dsce.getLiquidationBonus();
        dsce.getLiquidationPrecision();
        dsce.getLiquidationThreshold();
        dsce.getMinHealthFactor();
        dsce.getPrecision();
        dsce.getTokenAmountFromUsd(address(0), 0);
        dsce.getUsdValue(address(0), 0);
    }
}
