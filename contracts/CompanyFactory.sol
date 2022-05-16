// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Company.sol";

contract CompanyFactory {
    address[] public companiesList;

    function createNewCompany(
        uint256 _minAmountToJoin,
        uint256 _minAmountToPropose,
        uint256 _timeToActivateProposal,
        uint256 _timeToExcuteProposal
    ) public {
        Company _company = new Company(
            _minAmountToJoin,
            _minAmountToPropose,
            _timeToActivateProposal,
            _timeToExcuteProposal
        );
        companiesList.push(address(_company));
    }

    function listAllCompanies() public view returns (address[] memory) {
        return companiesList;
    }
}
