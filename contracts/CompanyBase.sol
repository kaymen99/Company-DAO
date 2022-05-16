// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract CompanyBase {
    // minimum amount staked to join the DAO
    uint256 public minAmountToJoin;

    uint256 public minAmountToPropose;

    // number of days to activate the proposal after it's creation
    uint256 public timeToActivateProposal;

    // number of days to excute the proposal after the voting succed
    uint256 public timeToExcuteProposal;

    mapping(address => Member) membersMapping;

    struct Member {
        uint256 stakedAmount;
        uint256 joinedAt;
    }

    event NewMemberAdded(address member, uint256 joinedAt);

    function stake() public payable {
        Member memory _member = membersMapping[msg.sender];
        if (_member.stakedAmount > 0) {
            _member.stakedAmount += msg.value;
        } else {
            require(msg.value > minAmountToJoin);
            _member = Member(msg.value, block.timestamp);
            emit NewMemberAdded(msg.sender, block.timestamp);
        }
        membersMapping[msg.sender] = _member;
    }

    function unStake(uint256 _amount) public {
        require(_amount > 0);
        uint256 _stakedAmount = membersMapping[msg.sender].stakedAmount;

        require(_amount <= _stakedAmount, "insuffisant amount");

        membersMapping[msg.sender].stakedAmount -= _amount;
        payable(msg.sender).transfer(_amount);

        // remove member if staked amount is 0
        if (_amount == _stakedAmount) {
            delete membersMapping[msg.sender];
        }
    }
}
