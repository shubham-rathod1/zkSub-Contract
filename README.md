# zkSub Contract

A modular, upgradeable smart contract system for subscription management with privacy-preserving features. Built using Solidity, OpenZeppelin upgradeable contracts, and Foundry for testing and scripting.

## Overview

This project implements a subscription platform where providers can create plans, and users can subscribe to them using ERC20 tokens. The contract supports upgradeability (UUPS), plan privacy, and is designed for extensibility.

## Key Contracts & Scripts

- **src/Logic.sol**: Main contract implementing plan creation, subscription logic, pausing, and upgradeability.
- **test/Logic.t.sol**: Comprehensive Foundry test suite for the `Logic` contract, covering plan creation, subscription, and edge cases.
- **script/Logic.s.sol**: Deployment script for the `Logic` contract and its proxy using Foundry scripting tools.

## Features

- **Plan Management**: Providers can create, deactivate, and manage subscription plans.
- **Subscription**: Users can subscribe to plans using ERC20 tokens, with support for private plans and subscriber limits.
- **Upgradeable**: Uses UUPS proxy pattern for upgradeability.
- **Pause/Unpause**: Contract owner can pause/unpause contract operations.

## Usage

### Deployment

Deploy the contract using the provided Foundry script:

```sh
forge script script/Logic.s.sol --broadcast --rpc-url <YOUR_RPC_URL>
```

### Running Tests

Run the test suite using:

```sh
forge test
```

### Example Functions

- `createPlan(bytes32 planId, address payout, address token, uint256 price, uint256 cycle, bool isPrivate, uint256 maxSubscribers)`
- `subscribe(bytes32 zkKey, bytes32 planId)`
- `deactivatePlan(bytes32 planId)`
- `pause()` / `unpause()`

See `src/Logic.sol` for full API and events.

## Directory Structure

```
├── src/Logic.sol         # Main contract
├── test/Logic.t.sol      # Tests
├── script/Logic.s.sol    # Deployment script
├── lib/                  # External dependencies (gitignored)
├── out/, cache/          # Build artifacts (gitignored)
├── .env                  # Environment variables (gitignored)
```

## Dependencies

- OpenZeppelin Contracts (Upgradeable)
- Foundry (forge, cast, anvil)

## Security & Notes

- The `lib/` directory is gitignored and should be managed via package manager.
- Always review and test thoroughly before deploying to production.
- Upgradeability is managed via UUPS; only the owner can authorize upgrades.

## License

MIT
