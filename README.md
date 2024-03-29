# OUSD Fuzzing Campaign

## Invariants
- Transfer
	-  The receiving account's balance after a transfer must not increase by less than the amount transferred
	- The receiving account's balance after a transfer must not increase by more than the amount transferred
	- The sending account's balance after a transfer must not decrease by less than the amount transferred
	- The sending account's balance after a transfer must not decrease by more than the amount transferred
	- The receiving account's balance after a transfer must not increase by less than the amount transferred (minus rounding error)
	- The sending account's balance after a transfer must not decrease by less than the amount transferred (minus rounding error)
	- An account should always be able to successfully transfer an amount within its balance.
	- An account should never be able to successfully transfer an amount greater than their balance.
	- A transfer to the same account should not change that account's balance
	- Transfers to the zero account revert
- Supply
	- After a `changeSupply`, the total supply should exactly match the target total supply. (This is needed to ensure successive rebases are correct).
	- The total supply must not be less than the sum of account balances. (The difference will go into future rebases)
	- Non-rebasing supply should not be larger than total supply
	- Global `rebasingCreditsPerToken` should never increase
	- The rebasing credits per token ratio must greater than zero
	- The sum of all non-rebasing balances should not be larger than non-rebasing supply
	- An accounts credits / credits per token should not be larger it's balance
- Accounting
	- After opting in, balance should not increase. (Ok to lose rounding funds doing this)
	- Account balance should remain the same after opting in minus rounding error
	- After opting out, balance should remain the same
	- After opting in, total supply should remain the same
	- After opting out, total supply should remain the same
	- Account balance should remain the same when a smart contract auto converts
	- The `balanceOf` function should never revert
- Mint & Burn
	- Minting 0 tokens should not affect account balance
	- Burning 0 tokens should not affect account balance
	- Minting tokens must increase the account balance by at least amount
	- Burning tokens must decrease the account balance by at least amount
	- Minting tokens should not increase the account balance by less than rounding error above amount
	- A burn of an account balance must result in a zero balance
	- You should always be able to burn an account's balance
- Approvals
	- Performing `transferFrom` with an amount inside the allowance should not revert
	- Performing `transferFrom` with an amount outside the allowance should revert
	- Approving an amount should update the allowance and overwrite any previous allowance
	- Increasing the allowance should raise it by the amount provided
	- Decreasing the allowance should lower it by the amount provided

