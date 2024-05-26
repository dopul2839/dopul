#!/bin/bash

# Start the DFX environment
echo "Starting the DFX environment..."
dfx start --clean --background

# Set up identities
echo "Setting up identities..."
echo "Creating the Minter identity..."
dfx identity new minter --storage-mode plaintext
echo "Using the Minter identity..."
dfx identity use minter
export MINTER=$(dfx identity get-principal)
echo "Minter identity created: $MINTER"
export TOKEN_NAME="DGSu Token"
export TOKEN_SYMBOL="DGSU"
export DEFAULT=$(dfx identity get-principal)
export PRE_MINTED_TOKENS=10000000000
export TRANSFER_FEE=10000

echo "Creating the Archive Controller identity..."
dfx identity new archive_controller --storage-mode plaintext
echo "Using the Archive Controller identity..."
dfx identity use archive_controller 
export ARCHIVE_CONTROLLER=$(dfx identity get-principal)
export TRIGGER_THRESHOLD=2000
export NUM_OF_BLOCK_TO_ARCHIVE=1000
export CYCLE_FOR_ARCHIVE_CREATION=1000000000000
export FEATURE_FLAGS=true
echo "Archive Controller identity created: $ARCHIVE_CONTROLLER"

echo "Using the Minter identity..."
dfx identity use minter

# Deploy the ICRC1 ledger canister
echo "Deploying the ICRC1 ledger canister..."
dfx deploy icrc1_ledger_canister --argument "(variant {Init =
record {
     token_symbol = \"${TOKEN_SYMBOL}\";
     token_name = \"${TOKEN_NAME}\";
     minting_account = record { owner = principal \"${MINTER}\" };
     transfer_fee = ${TRANSFER_FEE};
     metadata = vec {};
     feature_flags = opt record{icrc2 = ${FEATURE_FLAGS}};
     initial_balances = vec { record { record { owner = principal \"${DEFAULT}\"; }; ${PRE_MINTED_TOKENS}; }; };
     archive_options = record {
         num_blocks_to_archive = ${NUM_OF_BLOCK_TO_ARCHIVE};
         trigger_threshold = ${TRIGGER_THRESHOLD};
         controller_id = principal \"${ARCHIVE_CONTROLLER}\";
         cycles_for_archive_creation = opt ${CYCLE_FOR_ARCHIVE_CREATION};
     };
 }
})"

# Deploy the backend for ICRC1 ledger canister
echo "Deploying the backend for ICRC1 ledger canister..."
dfx deploy icrc1_ledger_canister_backend

# Create a new user and transfer tokens
dfx identity new user1 --storage-mode plaintext
dfx identity use user1
export USER1=$(dfx identity get-principal)
echo "User 1 identity created: $USER1"
dfx identity new user2 --storage-mode plaintext
dfx identity use user2
export USER2=$(dfx identity get-principal)
dfx identity use minter

dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${USER1}\";};  amount = 1000000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${USER1}\";})"

# Echo Canister ID of ICRC1 ledger canister backend
export ICRC1_LEDGER_CANISTER_BACKEND_ID=$(dfx canister id icrc1_ledger_canister_backend)
echo "Canister ID of ICRC1 ledger canister backend: ${ICRC1_LEDGER_CANISTER_BACKEND_ID}"

echo "Transferring tokens to ICRC1 ledger canister backend..."
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${ICRC1_LEDGER_CANISTER_BACKEND_ID}\";};  amount = 1000000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${ICRC1_LEDGER_CANISTER_BACKEND_ID}\";})"

# Deploy the NFT canister
echo "Deploying the NFT canister..."
dfx deploy dg_su_nft_canister --argument "(principal\"$(dfx identity get-principal)\", record { logo = record { logo_type = \"image/png\"; data = \"BASE64_IMAGE_DATA\"; }; name = \"DeGoldSilver\"; symbol = \"DGLSL\"; maxLimit = 20; })"

# Echo Canister ID of NFT canister
export DG_SU_NFT_CANISTER_ID=$(dfx canister id dg_su_nft_canister)
echo "Canister ID of NFT canister: ${DG_SU_NFT_CANISTER_ID}"

echo "Transfering tokens to NFT canister..."
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${DG_SU_NFT_CANISTER_ID}\";};  amount = 1000000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${DG_SU_NFT_CANISTER_ID}\";})"

# Add the MINTER as a validator
echo "Adding the MINTER as a validator..."
dfx canister call dg_su_nft_canister addValidator "(principal \"${MINTER}\", \"Minter Validator\")"

# Mint Gold NFTs
echo "Mint tokens to Users..."
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${USER1}\";};  amount = 100000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${USER1}\";})"
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${USER2}\";};  amount = 100000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${USER2}\";})"
echo "Minting Gold NFT 1 to User 1"
dfx canister call dg_su_nft_canister mintGoldNFT "(principal \"${USER1}\", vec { record { purpose = variant { Preview }; key_val_data = vec { record { key = \"description\"; val = variant { TextContent = \"Gold NFT 1\" } } }; data = blob \"\"; } }, 1, \"99.99%\")"
# dfx canister call dg_su_nft_canister mintGoldNFT "(principal \"sri5u-35qtg-ku5ia-wegbk-yrsun-b3nd4-f3gby-mxakf-pmxzq-urhzt-eqe\", vec { record { purpose = variant { Preview }; key_val_data = vec { record { key = \"description\"; val = variant { TextContent = \"Gold NFT 1\" } } }; data = blob \"\"; } }, 1, \"99.99%\")"
# sri5u-35qtg-ku5ia-wegbk-yrsun-b3nd4-f3gby-mxakf-pmxzq-urhzt-eqe
echo "Minting Gold NFT 2 to User 2"
dfx canister call dg_su_nft_canister mintGoldNFT "(principal \"${USER2}\", vec { record { purpose = variant { Preview }; key_val_data = vec { record { key = \"description\"; val = variant { TextContent = \"Gold NFT 2\" } } }; data = blob \"\"; } }, 1, \"99.99%\")"

# Check individual gold reserve
echo "Checking individual gold reserve..."
echo "User 1 Gold Reserves"
dfx canister call dg_su_nft_canister getIndividualGoldg "(principal \"${USER1}\")"
echo "User 2 Gold Reserves"
dfx canister call dg_su_nft_canister getIndividualGoldg "(principal \"${USER2}\")"

# Transfer Gold NFT
echo "Try to transfer Gold NFT 1 from User 1 to User 2 - Error Insufficient Balance (5000 tokens)"
dfx canister call dg_su_nft_canister transferGoldNFT "(principal \"${USER1}\", principal \"${USER2}\", 0, principal \"${USER1}\")"
echo "Transfering 10000 tokens to User 1..."
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${USER1}\";};  amount = 1000000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${USER1}\";})"
echo "Transfering 10000 tokens to User 2..."
dfx canister call icrc1_ledger_canister icrc1_transfer "(record { to = record { owner = principal \"${USER2}\";};  amount = 1000000000000;})"
dfx canister call icrc1_ledger_canister icrc1_balance_of "(record {owner = principal \"${USER2}\";})"
echo "Transfer Gold NFT 1 from User 1 to User 2"
dfx canister call dg_su_nft_canister transferGoldNFT "(principal \"${USER1}\", principal \"${USER2}\", 0, principal \"${USER1}\")"
echo "Updated User 1 Gold Reserves"
dfx canister call dg_su_nft_canister getIndividualGoldg "(principal \"${USER1}\")"
echo "Updated User 2 Gold Reserves"
dfx canister call dg_su_nft_canister getIndividualGoldg "(principal \"${USER2}\")"

echo "Deploying Internet Identity..."
dfx deploy internet_identity

echo "Deploying the frontend..."
dfx deploy icrc1_ledger_canister_frontend

echo "Script execution completed."
