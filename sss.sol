// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";
contract Foo {

    CommitReveal public commitReveal = new CommitReveal();
     mapping(address => bytes32) private player_choice_commit;
    mapping(address => uint) private player_choice;

    function getChoiceHash(uint randomNumber, uint choice) public view returns (bytes32) {
        bytes32 Hash = keccak256(abi.encodePacked(randomNumber, choice));
        bytes32 result = commitReveal.getHash(Hash);
        return result;
    }

    function inputCommit(bytes32 choiceHash) public {
        commitReveal.commit(choiceHash);
        player_choice_commit[msg.sender] = choiceHash;
    }


    function inputReveal(uint randomNumber, uint choice) public {
        bytes32 choiceHash = keccak256(abi.encodePacked(randomNumber, choice));
        
        commitReveal.reveal(choiceHash);
        
        uint revealedChoice = uint8(choice);
        require(revealedChoice <= 4 && revealedChoice >= 0);
        player_choice[msg.sender] = revealedChoice;
        
    }
}