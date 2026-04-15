// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEthermonLite {
    function initMonster(string memory _monsterName) external;
    function getName(address _monsterAddress) external view returns (string memory);
    function getFullName(address _monsterAddress) external view returns (string memory);
    function getNumWins(address _monsterAddress) external view returns (uint);
    function getNumLosses(address _monsterAddress) external view returns (uint);
    function battle() external returns (bool);
    function renameTitle(string calldata _newTitle) external;
}

/**
 * This includes a function you might find useful! You can run this by, for example, calling
 * `StringTools.makeString(32);`
 */
library StringTools {
    /**
     * Turns a uint256 number into a string representing the number. This
     * function might be useful to you if you plan to change the challenger
     * name. It's NOT necessary to use this to win.
     * @param number Number to convert to a string.
     * @return string form of the number
     */
    function makeString(uint256 number) internal pure returns (string memory) {
        if (number == 0) {
            return "0";
        }
        uint strLen = 0;
        uint x = number;
        while (x > 0) {
            x /= 10;
            strLen++;
        }
        bytes memory strBytes = new bytes(strLen);
        x = number;
        for (uint i = 0; i < strLen; i++) {
            strBytes[strLen - i - 1] = bytes1(uint8(48 + (x % 10)));
            x /= 10;
        }
        return string(strBytes);
    }
}

contract WinBattle {
    IEthermonLite public immutable ethermon;
    string public netID;
    uint256 public constant BATTLE_RATIO = 64;

    constructor(address ethermonAddress, string memory _netID) {
        ethermon = IEthermonLite(ethermonAddress);
        netID = _netID;
        ethermon.initMonster(_netID);
    }

    function winBattles(uint256 numBattles) public {
        ethermon.renameTitle(_findWinningTitle());

        for (uint256 i = 0; i < numBattles; i++) {
            require(ethermon.battle(), "Unexpected loss");
        }
    }

    function win50() external {
        winBattles(50);
    }

    function getStats() external view returns (uint256 wins, uint256 losses) {
        return (
            ethermon.getNumWins(address(this)),
            ethermon.getNumLosses(address(this))
        );
    }

    function _findWinningTitle() internal view returns (string memory) {
        uint256 previousBlockHash = uint256(blockhash(block.number - 1));

        for (uint256 i = 0; i < 512; i++) {
            string memory title = StringTools.makeString(i);
            uint256 challengerDice = previousBlockHash ^ uint256(sha256(abi.encodePacked(netID, " ", title)));

            if (challengerDice % BATTLE_RATIO == 0) {
                return title;
            }
        }

        revert("No winning title found");
    }
}
