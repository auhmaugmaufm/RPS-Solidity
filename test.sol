// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";

contract Test {
    CommitReveal public commitReveal = new CommitReveal();
    mapping(address => bytes32) private player_choice_commit;
    mapping(address => uint) private player_choice;
    function input(bytes32 choiceHash) public {

        commitReveal.commit(commitReveal.getHash(choiceHash));
        //commitReveal.commit(choiceHash);
        player_choice_commit[msg.sender] = choiceHash;

    }


    function reveal(uint randomNumber, uint choice) public returns (bytes32) {
        bytes32 hexValue = bytes32(randomNumber);
        
        // Convert the choice to a fixed-width byte (00, 01, 02, 03, 04)
        bytes1 choiceByte = bytes1(uint8(choice));

        // Concatenate the randomBytes and choiceByte together
        bytes memory combined = abi.encodePacked(hexValue, choiceByte);

        // commitReveal.reveal(bytes32(combined));
        uint revealedChoice = choice;
        require(revealedChoice <= 4 && revealedChoice >= 0);
        player_choice[msg.sender] = revealedChoice;
        return bytes32(combined);
    }

    function toHex(uint256 randomNumber) public pure returns (bytes32) {
        // แปลงจาก uint256 ไปเป็น bytes32 โดยตรง
        bytes32 hexValue = bytes32(randomNumber);
        //bytes32 test = commitReveal.getHash(hexValue);
        return hexValue;
    }
    function toHash(bytes32 test) public view returns (bytes32) {
        bytes32 sss = commitReveal.getHash(test);
        return sss;
    }
    function toHash2(uint randomNumber, uint choice) public pure returns (bytes32) {
        // แปลง randomNumber เป็น bytes32
        bytes32 hexValue = bytes32(randomNumber);

        // แปลง choice ให้เป็น bytes1
        bytes1 choiceByte = bytes1(uint8(choice));

        // เชื่อมต่อ hexValue (bytes32) และ choiceByte (bytes1)
        bytes memory combined = abi.encodePacked(hexValue, choiceByte);

        // ใช้ keccak256 เพื่อสร้าง hash จาก combined ที่มีข้อมูลครบถ้วน
        bytes32 result = keccak256(combined);

        return result;
    }
}