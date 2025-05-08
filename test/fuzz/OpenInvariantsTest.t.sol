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

contract OpenInvariantsTests is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    HelperConfig config;
    DecentralizedStableCoin dsc;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        targetContract(address(dsce));
    }

    function invariant_openProtocolMustHaveMoreValueThanTotalSupply() public view {
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

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
