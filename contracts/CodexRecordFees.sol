pragma solidity ^0.4.24;

import "./ERC20/ERC20.sol";
import "./ERC900/ERC900.sol";

import "./library/Pausable.sol";


/**
 * @title CodexRecordFees
 * @dev Storage, mutators, and modifiers for fees when using the token.
 *  This also includes the Pausable contract for the onlyOwner modifier.
 */
contract CodexRecordFees is Pausable {

  // Implementation of the ERC20 Codex Protocol Token, used for fees in the contract
  ERC20 public codexCoin;

  // Implementation of the ERC900 Codex Protocol Stake Container,
  //  used to calculate discounts on fees
  ERC900 public codexStakeContainer;

  // Address where all contract fees are sent, i.e., the Community Fund
  address public feeRecipient;

  // Fee to create new tokens. 10^18 = 1 token
  uint256 public creationFee = 0;

  // Fee to transfer tokens. 10^18 = 1 token
  uint256 public transferFee = 0;

  // Fee to modify tokens. 10^18 = 1 token
  uint256 public modificationFee = 0;

  // Parameters in the polynomial used to calculate discount
  // Current range of discount is 0-100% (i.e., stake enough tokens for a 100% discount!)
  uint256 public lowerBound = 0;
  uint256 public upperBound = 100;

  modifier canPayFees(uint256 baseFee) {
    if (feeRecipient != address(0)) {
      // @TODO: Update the discount to be based on weight as opposed to just
      //  a binary on/off value
      uint256 calculatedFee = baseFee;
      if (codexStakeContainer != address(0) &&
        codexStakeContainer.totalStakedFor(msg.sender) > 0) {

        calculatedFee = 0;
      }

      require(
        codexCoin.transferFrom(msg.sender, feeRecipient, calculatedFee),
        "Fee in CODX required");
    }

    _;
  }

  /**
   * @dev Sets the address of the ERC20 token used for fees in the contract.
   *  Fees are in the smallest denomination, e.g., 10^18 is 1 token.
   * @param _codexCoin ERC20 The address of the ERC20 Codex Protocol Token
   * @param _feeRecipient address The address where the fees are sent
   * @param _creationFee uint256 The new creation fee.
   * @param _transferFee uint256 The new transfer fee.
   * @param _modificationFee uint256 The new modification fee.
   */
  function setFees(
    ERC20 _codexCoin,
    address _feeRecipient,
    uint256 _creationFee,
    uint256 _transferFee,
    uint256 _modificationFee)
    external onlyOwner
  {
    codexCoin = _codexCoin;
    feeRecipient = _feeRecipient;
    creationFee = _creationFee;
    transferFee = _transferFee;
    modificationFee = _modificationFee;
  }

  function setStakeContainer(ERC900 _codexStakeContainer) external onlyOwner {
    codexStakeContainer = _codexStakeContainer;
  }
}