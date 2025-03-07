// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPS {
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping (address => uint) public player_choice; // 0 - Scissors, 1 - Paper , 2 - Rock , 3 - Lizard , 4 - Spock : (x+1)%5, (x+3)%5
    mapping(address => bool) public player_not_played;
    address[] public players;
    uint public numInput = 0;
    TimeUnit public timeUnit = new TimeUnit();
    uint public timeOut = 1 ;

    address[4] private playerAccept = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    function getValid () public view returns (bool) {
        for (uint256 i = 0; i < 4; i++) {
            if(msg.sender == playerAccept[i]) {
                return true;
            }
        }
        return false;
    }

    function addPlayer() public payable {
        require(numPlayer < 2);
        require(getValid());
        require(msg.value == 1 ether);
        reward += msg.value;
        player_not_played[msg.sender] = true;
        players.push(msg.sender);
        numPlayer++;
        if(numPlayer==1){
            timeUnit.setStartTime();
        } 
    }

    function input(uint choice) public {
        require(numPlayer == 2);
        require(player_not_played[msg.sender]);
        require(choice >= 0 && choice <= 4);
        player_choice[msg.sender] = choice;
        player_not_played[msg.sender] = false;
        numInput++;
        if (numInput == 2) {
            numInput = 0;
            numPlayer = 0;
            _checkWinnerAndPay();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = player_choice[players[0]];
        uint p1Choice = player_choice[players[1]];
        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);
        if (p0Choice == p1Choice) {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        else if ((p1Choice + 1) % 5 == p0Choice || (p1Choice + 3) % 5 == p0Choice) {
            account0.transfer(reward); // player 0 ชนะ 
        }
        else {
            account1.transfer(reward); // player 1 ชนะ
        }
        reward = 0;
    }

    function checkTimeOut() public {
        if(timeUnit.elapsedMinutes() == timeOut) {
            for (uint256 i = 0; i < 2; i++) {
                if(!player_not_played[players[i]]) {
                    address payable account = payable(players[i]);
                    account.transfer(reward);
                    numInput = 0;
                    numPlayer = 0;
                    reward = 0;
                }
            }
        }
    }

}