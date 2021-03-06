// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.6.12;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./interfaces/IAdmins.sol";
import "./interfaces/IOperators.sol";
import "./interfaces/ISettings.sol";

/**
 * @title Settings
 *
 * @dev Contract for storing global settings.
 * Can mostly be changed by accounts with an admin role.
 */
contract Settings is ISettings, Initializable {
    // @dev The address of the application owner, where the fee will be paid.
    address payable public override maintainer;

    // @dev The percentage fee users pay from their reward for using the service.
    uint64 public override maintainerFee;

    // @dev The minimal unit (wei, gwei, etc.) deposit can have.
    uint64 public override userDepositMinUnit;

    // @dev The deposit amount required to become an Ethereum validator.
    uint128 public override validatorDepositAmount;

    // @dev The withdrawal credentials used to initiate validator withdrawal from the beacon chain.
    bytes public override withdrawalCredentials;

    // @dev The mapping between collector and its staking duration.
    mapping(address => uint256) public override stakingDurations;

    // @dev The mapping between the managed contract and whether it is paused or not.
    mapping(address => bool) public override pausedContracts;

    // @dev Address of the Admins contract.
    IAdmins private admins;

    // @dev Address of the Operators contract.
    IOperators private operators;

    /**
     * @dev See {ISettings-initialize}.
     */
    function initialize(
        address payable _maintainer,
        uint16 _maintainerFee,
        uint64 _userDepositMinUnit,
        uint128 _validatorDepositAmount,
        bytes memory _withdrawalCredentials,
        address _admins,
        address _operators
    )
        public override initializer
    {
        maintainer = _maintainer;
        maintainerFee = _maintainerFee;
        userDepositMinUnit = _userDepositMinUnit;
        validatorDepositAmount = _validatorDepositAmount;
        withdrawalCredentials = _withdrawalCredentials;
        admins = IAdmins(_admins);
        operators = IOperators(_operators);
    }

    /**
     * @dev See {ISettings-setUserDepositMinUnit}.
     */
    function setUserDepositMinUnit(uint64 newValue) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");

        userDepositMinUnit = newValue;
        emit SettingChanged("userDepositMinUnit");
    }

    /**
     * @dev See {ISettings-setValidatorDepositAmount}.
     */
    function setValidatorDepositAmount(uint128 newValue) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");

        validatorDepositAmount = newValue;
        emit SettingChanged("validatorDepositAmount");
    }

    /**
     * @dev See {ISettings-setWithdrawalCredentials}.
     */
    function setWithdrawalCredentials(bytes calldata newValue) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");

        withdrawalCredentials = newValue;
        emit SettingChanged("withdrawalCredentials");
    }

    /**
     * @dev See {ISettings-setMaintainer}.
     */
    function setMaintainer(address payable newValue) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");

        maintainer = newValue;
        emit SettingChanged("maintainer");
    }

    /**
     * @dev See {ISettings-setMaintainerFee}.
     */
    function setMaintainerFee(uint64 newValue) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");
        require(newValue < 10000, "Invalid value.");

        maintainerFee = newValue;
        emit SettingChanged("maintainerFee");
    }

    /**
     * @dev See {ISettings-setStakingDuration}.
     */
    function setStakingDuration(address collector, uint256 stakingDuration) external override {
        require(admins.isAdmin(msg.sender), "Permission denied.");

        stakingDurations[collector] = stakingDuration;
        emit SettingChanged("stakingDurations");
    }

    /**
     * @dev See {ISettings-setContractPaused}.
     */
    function setContractPaused(address _contract, bool isPaused) external  override {
        require(admins.isAdmin(msg.sender) || operators.isOperator(msg.sender), "Permission denied.");

        pausedContracts[_contract] = isPaused;
        emit SettingChanged("pausedContracts");
    }
}
