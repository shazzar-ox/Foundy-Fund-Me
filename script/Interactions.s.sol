// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant fundValue = 0.1 ether;

    function fundFundMe(address mostRecentDeployemnt) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployemnt)).fund{value: fundValue}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", fundValue);
    }

    function run() external {
        address mostRecentDeployemnt = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        fundFundMe(mostRecentDeployemnt);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
