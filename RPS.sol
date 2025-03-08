// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPS {
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping(address => bytes32) private player_choice_commit;
    mapping(address => uint) private player_choice;
    mapping(address => bool) public player_not_played;
    address[] public players;
    uint public numInput = 0;

    TimeUnit private timeUnit = new TimeUnit();
    uint private timeOut = 1;
    CommitReveal public commitReveal = new CommitReveal();

    address[4] private playerAccept = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    function getValid() private view returns (bool) {
        for (uint256 i = 0; i < 4; i++) {
            if (msg.sender == playerAccept[i]) {
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

        if (numPlayer == 1) {
            timeUnit.setStartTime();
        }
    }

    function input(bytes32 choiceHash) public {
        require(numPlayer == 2);
        require(player_not_played[msg.sender]);
        commitReveal.commit(commitReveal.getHash(choiceHash));
        player_choice_commit[msg.sender] = choiceHash;
        player_not_played[msg.sender] = false;
        numInput++;
    }


    function reveal(uint randomNumber, bytes1 choice) public {
        require(numPlayer == 2);
        require(numInput == 2);
        
        bytes32 randomNumberBytes32 = bytes32(randomNumber);
        bytes32 choiceHash = keccak256(abi.encodePacked(randomNumberBytes32, choice));
        
        require(choiceHash == player_choice_commit[msg.sender], "Choice hash mismatch");
        
        commitReveal.reveal(choiceHash);
        
        uint revealedChoice = uint8(choice);
        require(revealedChoice <= 4 && revealedChoice >= 0);
        player_choice[msg.sender] = revealedChoice;
        
        if (numInput == 2) {
            numInput = 0;
            numPlayer = 0;
            checkWinnerAndPay();
        }
    }


    function checkWinnerAndPay() private {
        uint p0Choice = player_choice[players[0]];
        uint p1Choice = player_choice[players[1]];
        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);

        if (p0Choice == p1Choice) {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        } else if ((p1Choice + 1) % 5 == p0Choice || (p1Choice + 3) % 5 == p0Choice) {
            account0.transfer(reward);
        } else {
            account1.transfer(reward);
        }

        reward = 0;
    }

    function resetGame() private {
        delete players;
        numInput = 0;
        numPlayer = 0;
        reward = 0;
    }

    function checkTimeOut() public {
        if (timeUnit.elapsedMinutes() >= timeOut) {
            if (players.length == 1) {
                address payable account = payable(players[0]);
                account.transfer(reward);
            } else if (numPlayer == 2 && numInput == 2) {
                address payable account0 = payable(players[0]);
                address payable account1 = payable(players[1]);
                account0.transfer(reward / 2);
                account1.transfer(reward / 2);
            } else {
                for (uint256 i = 0; i < 2; i++) {
                    if (!player_not_played[players[i]]) {
                        address payable account = payable(players[i]);
                        account.transfer(reward);
                    }
                }
            }
            resetGame();
        }
    }
}
