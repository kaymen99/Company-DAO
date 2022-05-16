// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CompanyProposals.sol";

contract Company is CompanyProposals {
    constructor(
        uint256 _minAmountToJoin,
        uint256 _minAmountToPropose,
        uint256 _timeToActivateProposal,
        uint256 _timeToExcuteProposal
    ) {
        minAmountToJoin = _minAmountToJoin;
        minAmountToPropose = _minAmountToPropose;
        timeToActivateProposal = _timeToActivateProposal;
        timeToExcuteProposal = _timeToExcuteProposal;
    }
}
