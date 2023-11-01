// SPDX-License-Identifier: MI

pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
// import {Script} from "forge-std/Script.sol";

contract FundMeIntegrations is Test {
    // function setUp is always the first function to run in a foundry test..
    FundMe fundMe;

    address User = makeAddr("user"); // creates an automatic address for name user...name can be anything

    uint256 constant SEND_ETHER = 0.1 ether;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(address(User), 10 ether);
    }

    function testUSerCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(User);
        fundFundMe.fundFundMe(address(fundMe));
        address funder = fundMe.getFunder(0);
        assertEq(funder, msg.sender);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
