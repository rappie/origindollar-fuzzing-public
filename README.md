# OUSD Fuzzing Campaign

**NOTE** This repo is work in progress.

## Invariants

- Transfer
	- The receiving account's balance after a transfer must increase by at least the amount transferred.
	- The sending account's balance after a transfer must decrease by no more than amount transferred.
	- An account should always be able to successfully transfer an amount within its balance.
	- An account should never be able to successfully transfer an amount greater than their balance.
	- A transfer to the same account should not change that account's balance
	- Transfers to the zero account revert
- Change Supply
	- After a `changeSupply`, the total supply should exactly match the target total supply. (This is needed to ensure successive rebases are correct).
	- The total supply may be greater than the sum of account balances. (The difference will go into future rebases)
	- Non-rebasing supply should not be larger than total supply
	- Global `rebasingCreditsPerToken` should never increase
- Accounting
	- After opting in, balance should not increase. (Ok to lose rounding funds doing this)
	- After opting out, balance should remain the same
	- After opting in, total supply should remain the same
	- After opting out, total supply should remain the same
	- Account balance should remain the same when a smart contract auto converts
- Balances
	- The `balanceOf` function should never revert
	- The rebasing credits per token ratio must greater than zero
- Mint & Burn
	- Minting 0 tokens should not affect account balance
	- Burning 0 tokens should not affect account balance
	- Minting tokens should always increase the account balance by at least amount
	- Burning tokens must decrease the balance by at least amount.
	- A burn of an account balance must result in a zero balance
	- You should always be able to burn an account's balance
