// SPDX-License-Identifier: MI

pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
// import {Script} from "forge-std/Script.sol";

contract FundMeTest is Test {
    // function setUp is always the first function to run in a foundry test..
    FundMe fundMe;

    address User = makeAddr("user"); // creates an automatic address for name user...name can be anything

    uint256 constant SEND_ETHER = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(address(User), 10 ether); // deal can be used to send tokens to another address...
    }

    function testMinimumDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersion() public {
        console.log(fundMe.getVersion());
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundsFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund{value: 1e8}();
    }

    function testFundsSendsWithEnoughETH() public {
        vm.prank(User); // the next transaction should be sent via this
        fundMe.fund{value: SEND_ETHER}();
        uint256 balance = fundMe.getAddressToAmountFunded(User);
        console.log(balance);
        assertEq(balance, SEND_ETHER);
    }

    function testAddsFundersToArrayOfFunders() public {
        vm.prank(User); // the next transaction should be sent via this
        fundMe.fund{value: SEND_ETHER}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, User);
    }

    // to prevent repetition of code we can  make use of modifiers....
    modifier funded() {
        vm.prank(User); // the next transaction should be sent via this
        fundMe.fund{value: SEND_ETHER}();
        _;
    }

    function testOnlyOwnerCanWIthdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 statingFundMeBalance = address(fundMe).balance;

        assertEq(statingFundMeBalance, 0.1 ether);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(address(fundMe).balance, 0 ether);
    }

    function testWithmultipleFunders() public funded {
        uint160 numberOfFunders = 10; // 160 cause its a direct representation of the bytes of an address...
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            // prank connects an address toa trasaction while deal funds  the address,..
            // hoax does both at once
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: SEND_ETHER}();
        }
        uint256 statingFundMeBalance = address(fundMe).balance;
        assertEq(statingFundMeBalance, 1 ether);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(address(fundMe).balance, 0 ether);
    }
}
