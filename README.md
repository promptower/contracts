# CTP NFTs

This project implements two kinds of NFTs:
- A custom minimal 6551 structure for games
- Soulbound Tokens (SBT) for badges

## Minimal 6551 Contract

- **TokenID**: The `tokenId` is represented as a zero-padded contract wallet address (e.g., `0x0000...00001234...1234`). The owner of the wallet, who can issue `call` commands through the wallet, is changed when the NFT is transferred.
- **Contract Wallet**: This wallet holds Badge SBTs, allowing it to perform actions based on the badges it holds. It also holds awards `USDC`.
- **Metadata**: The following data is associated with the wallet:
    - Hash of prompt
    - Hash of secret (if applicable)
    - Start date
    - End date
    - Winner address (once a winner is announced)

## Badge SBT (Soulbound Token)

- **Non-transferability**: Since the Badge is non-transferable, using it within the 6551 structure makes it an appropriate choice.
- **Example Use Case**: In ExampleDAO, only verified Badge holders are permitted to participate. The Badge is held within the 6551 wallet, which can be accessed and controlled by the NFT owner, allowing them to engage in governance and decision-making.
