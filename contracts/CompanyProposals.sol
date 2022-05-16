// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CompanyBase.sol";

contract CompanyProposals is CompanyBase {
    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) proposalVotersMappings;

    struct Proposal {
        address submitter;
        string subject;
        string description;
        uint256 createdAt;
        uint256 deadline;
        uint256 forVotesCount;
        ProposalStatus status;
    }

    enum ProposalStatus {
        CREATED,
        ACTIVE,
        REJECTED,
        QUEUED,
        EXECUTED
    }

    modifier canPropose(address _sender) {
        require(
            membersMapping[_sender].stakedAmount > minAmountToPropose,
            "insuffisant shares to propose"
        );
        _;
    }

    function createProposal(
        string memory _subject,
        string memory _description,
        uint256 _deadline
    ) public canPropose(msg.sender) {
        proposals.push(
            Proposal(
                msg.sender,
                _subject,
                _description,
                block.timestamp,
                _deadline,
                0,
                ProposalStatus.CREATED
            )
        );
    }

    function activate(uint256 _id) public {
        Proposal memory _proposal = proposals[_id];
        uint256 activationWaitDuration = _proposal.createdAt +
            timeToActivateProposal;
        require(block.timestamp > activationWaitDuration, "duration not ended");

        _proposal.status = ProposalStatus.ACTIVE;
        proposals[_id] = _proposal;
    }

    // vote to approve proposal
    function vote(uint256 _id) public canPropose(msg.sender) {
        Proposal memory _proposal = proposals[_id];

        require(
            _proposal.status == ProposalStatus.ACTIVE,
            "proposal not active"
        );

        // only member presente before proposal creation are allowed to vote
        require(
            membersMapping[msg.sender].joinedAt <= _proposal.createdAt,
            "Not allowed to vote"
        );

        proposalVotersMappings[_id][msg.sender] = true;
        _proposal.forVotesCount += membersMapping[msg.sender].stakedAmount;

        proposals[_id] = _proposal;
    }

    // change vote to refuse proposal
    function unVote(uint256 _id) public {
        Proposal memory _proposal = proposals[_id];

        require(
            _proposal.status == ProposalStatus.ACTIVE,
            "proposal not active"
        );

        require(proposalVotersMappings[_id][msg.sender], "didn't vote yet");

        proposalVotersMappings[_id][msg.sender] = false;
        _proposal.forVotesCount -= membersMapping[msg.sender].stakedAmount;

        proposals[_id] = _proposal;
    }

    function endVoting(uint256 _id) public {
        Proposal memory _proposal = proposals[_id];

        require(
            _proposal.status == ProposalStatus.ACTIVE,
            "proposal not active"
        );
        require(
            block.timestamp >= _proposal.deadline,
            "not proposal deadline yet"
        );

        uint256 votesCountForApprovingProposal = address(this).balance / 2;

        if (_proposal.forVotesCount > votesCountForApprovingProposal) {
            _proposal.status = ProposalStatus.QUEUED;
        } else {
            _proposal.status = ProposalStatus.REJECTED;
        }
        proposals[_id] = _proposal;
    }

    function executeProposal(uint256 _id) public {
        Proposal memory _proposal = proposals[_id];

        require(
            _proposal.status == ProposalStatus.QUEUED,
            "proposal not in queue"
        );

        uint256 excutionWaitDuration = _proposal.deadline +
            timeToExcuteProposal;
        require(
            block.timestamp >= excutionWaitDuration,
            "Excution delay not over yet"
        );

        _proposal.status = ProposalStatus.EXECUTED;
        proposals[_id] = _proposal;
    }

    function getAllProposals() public view returns (Proposal[] memory) {
        return proposals;
    }
}
