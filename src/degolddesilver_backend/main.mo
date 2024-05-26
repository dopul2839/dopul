import Icrc1Ledger "canister:icrc1_ledger_canister";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";

import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Blob "mo:base/Blob";

// TrieMap
import TrieMap "mo:base/TrieMap";

actor DGSuCanister {
  let limit = 10_000_000_000;

  public func wallet_balance() : async Nat {
    return Cycles.balance();
  };

  public func wallet_receive() : async { accepted: Nat64 } {
    let available = Cycles.available();
    let accepted = Cycles.accept(Nat.min(available, limit));
    { accepted = Nat64.fromNat(accepted) };
  };

  public func transfer(
    receiver : shared () -> async (),
    amount : Nat) : async { refunded : Nat } {
      Cycles.add(amount);
      await receiver();
      { refunded = Cycles.refunded() };
  };
  
  let IC =
    actor "aaaaa-aa" : actor {
      create_canister :{
    } -> async { canister_id: Principal };
    canister_status : { canister_id: Principal } -> async { cycles: Nat };
    stop_canister : { canister_id: Principal } -> async ();
    delete_canister : { canister_id: Principal } -> async ();
    };

  public func burn() : async () {
    Debug.print("balance before: " # Nat.toText(Cycles.balance()));
    Cycles.add(Cycles.balance()/2);
    let cid = await IC.create_canister({});
    let status = await IC.canister_status(cid);
    Debug.print("cycles: " # Nat.toText(status.cycles));
    await IC.stop_canister(cid);
    await IC.delete_canister(cid);
    Debug.print("balance after: " # Nat.toText(Cycles.balance()));
  };
    

  type Tokens = {
    e8s: Nat64;
  };

  public type Subaccount = Blob;
  type Account = {
    owner: Principal;
    subaccount: ?Subaccount;
  };

  type TransferArgs = {
    amount: Nat;
    toAccount: Account;
    toSubaccount: ?Blob;
  };

  public shared ({ caller }) func transfer2(args : TransferArgs) : async Result.Result<Icrc1Ledger.BlockIndex, Text> {
    Debug.print(
      "Transferring "
      # debug_show (args.amount)
      # " tokens to principal "
      # debug_show (args.toAccount)
      # " subaccount "
      # debug_show (args.toSubaccount)
    );

    let transferArgs : Icrc1Ledger.TransferArg = {
      // can be used to distinguish between transactions
      memo = null;
      // the amount we want to transfer
      amount = args.amount;
      // the ICP ledger charges 10_000 e8s for a transfer
      fee = null;
      // we are transferring from the canisters default subaccount, therefore we don't need to specify it
      from_subaccount = null;
      // we take the principal and subaccount from the arguments and convert them into an account identifier
      to = {
        owner = args.toAccount.owner;
        subaccount = null;
      };
      // a timestamp indicating when the transaction was created by the caller; if it is not specified by the caller then this is set to the current ICP time
      created_at_time = null;
    };

    try {
      // initiate the transfer
      let transferResult = await Icrc1Ledger.icrc1_transfer(transferArgs);

      // check if the transfer was successfull
      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds:\n" # debug_show (transferError));
        };
        case (#Ok(blockIndex)) { return #ok blockIndex };
      };
    } catch (error : Error) {
      // catch any errors that might occur during the transfer
      return #err("Reject message: " # Error.message(error));
    };
  };

  // Mint tokens to a specific account
  public shared({ caller }) func mintTokens(to: Principal, amount: Nat): async Result.Result<Nat, Text> {
    let mintingAccount: Account = { owner = Principal.fromText("p4rvf-lmh56-asfn2-wum37-fxjs3-s5aha-pw4oq-sut4v-77o57-ny3dz-oae"); subaccount = null };

    let transferArgs: Icrc1Ledger.TransferArg = {
      from_subaccount = null;
      to = { owner = to; subaccount = null };
      amount = amount;
      fee = null;
      memo = null;
      created_at_time = null;
    };

    try {
      // Print caller principal
      Debug.print("Caller: " # Principal.toText(caller));
      // Print caller balance
      let callerBalance = await Icrc1Ledger.icrc1_balance_of({ owner = caller; subaccount = null });
      Debug.print("Caller balance: " # debug_show(callerBalance));
      // Print minting account balance
      let accountObj = {
        owner = mintingAccount.owner;
        subaccount = null;
      };
      let balance = await Icrc1Ledger.icrc1_balance_of(accountObj);
      Debug.print("Minting account balance: " # debug_show(balance));
      // Debug show transferArgs
      Debug.print("Transfer Args: " # debug_show(transferArgs));

      // Ensure that the transfer is initiated from the minting account
      let transferResult = await Icrc1Ledger.icrc1_transfer({
        from_subaccount = null;
        to = transferArgs.to;
        amount = transferArgs.amount;
        fee = transferArgs.fee;
        memo = transferArgs.memo;
        created_at_time = transferArgs.created_at_time;
      });

      switch (transferResult) {
        case (#Err(transferError)) {
          Debug.print("Minting account: " # Principal.toText(mintingAccount.owner));
          Debug.print("To account: " # Principal.toText(transferArgs.to.owner));
          Debug.print("Minting account balance: " # debug_show(balance));
          Debug.print("Couldn't mint tokens(mintTokens): " # debug_show(transferError));
          return #err("Couldn't mint tokens(mintTokens): \n" # debug_show(transferError));
        };
        case (#Ok(_)) {
          Debug.print("Mint successful");
          return #ok(amount);
        };
      };
    } catch (error: Error) {
      Debug.print("Reject message: " # Error.message(error));
      return #err("Reject message: " # Error.message(error));
    }
  };

  // get principal of canister
  public shared({ caller }) func getPrincipal(): async Principal {
    let principalofcanister = Principal.fromActor(DGSuCanister);
    Debug.print("Principal of canister: " # Principal.toText(principalofcanister));
    return principalofcanister;
  };


  public shared({ caller }) func mintAndTransferTokens(validator: Principal, user: Principal, validatorReward: Nat, userReward: Nat): async Result.Result<Nat, Text> {
    // Mint tokens to this canister's account
    let mintAmount = validatorReward + userReward;
    // print caller principal
    Debug.print("Caller: " # Principal.toText(caller));
    // print caller balance
    let callerBalance = await balanceOf(caller);
    Debug.print("Caller balance: " # debug_show(callerBalance));
    // print balance using balance_of
    let balance = await balance_Of({ owner = caller; subaccount = null });
    let mintResult = await mintTokens(validator, mintAmount);

    switch (mintResult) {
      case (#err(err)) {
        Debug.print("Couldn't mint tokens(mintAndTransferTokens): " # err);
        return #err(err);
      };
      case (#ok(_)) {
        Debug.print("Minted tokens");
      };
    };

     // Transfer tokens from validator to user
    let userTransfer = await transferTokens({
      amount = userReward;
      toAccount = { owner = user; subaccount = null };
      fromAccount = { owner = validator; subaccount = null };
      toSubaccount = null;
    });
    switch (userTransfer) {
      case (#err(err)) {
        Debug.print("Couldn't transfer to user: " # err);
        return #err(err);
      };
      case (#ok(blockIndex)) {
        Debug.print("Transferred to user");
        return #ok(blockIndex);
      };
    };
  };



  public shared({ caller }) func transferTokens(args: TransferArgs): async Result.Result<Icrc1Ledger.BlockIndex, Text> {
    Debug.print(
      "Transferring "
      # debug_show(args.amount)
      # " tokens to account "
      # debug_show(args.toAccount)
    );

    let transferArgs: Icrc1Ledger.TransferArg = {
      memo = null;
      amount = args.amount;
      from_subaccount = null;
      fee = null;
      to = {
        owner = args.toAccount.owner;
        subaccount = null;
      };
      created_at_time = null;
    };

    try {
      // debug show transferArgs
      Debug.print("Transfer Args: " # debug_show(transferArgs));
      // debug show caller balance
      let callerBalance = await Icrc1Ledger.icrc1_balance_of({ owner = caller; subaccount = null });
      Debug.print("Caller balance: " # debug_show(callerBalance));
      // debug show receiver balance
      let accountObj = {
        owner = args.toAccount.owner;
        subaccount = null;
      };
      // let balance = await Icrc1Ledger.icrc1_balance_of(accountObj);
      let receiverBalance = await Icrc1Ledger.icrc1_balance_of(accountObj);
      Debug.print("Receiver balance: " # debug_show(receiverBalance));
      let transferResult = await Icrc1Ledger.icrc1_transfer(transferArgs);
      switch (transferResult) {
        case (#Err(transferError)) {
          Debug.print("Couldn't transfer funds: " # debug_show(transferError));
          return #err("Couldn't transfer funds: \n" # debug_show(transferError));
        };
        case (#Ok(blockIndex)) {
          Debug.print("Transfer successful");
          return #ok(blockIndex);
        };
      };
    } catch (error: Error) {
      Debug.print("Reject message: " # Error.message(error));
      return #err("Reject message: " # Error.message(error));
    }
  };

  public shared({ caller = _ }) func balanceOf(user: Principal): async Result.Result<Nat, Text> {
    let account: Icrc1Ledger.Account = { owner = user; subaccount = null };
    try {
      let balance = await Icrc1Ledger.icrc1_balance_of(account);
      return #ok(balance);
    } catch (error) {
      return #err("Error fetching balance: " # Error.message(error));
    }
  };

  // token name
  public shared({ caller }) func name(): async Text {
    let name = await Icrc1Ledger.icrc1_name();
    // show name 
    Debug.print("Token Name: " # name);
    return name;
  };

  // token symbol
  public shared({ caller }) func symbol(): async Text {
    let symbol = await Icrc1Ledger.icrc1_symbol();
    // show symbol
    Debug.print("Token Symbol: " # symbol);
    return symbol;
  };

  // token decimals
  public shared({ caller }) func decimals(): async Nat8 {
    let decimals = await Icrc1Ledger.icrc1_decimals();
    // show decimals
    Debug.print("Token Decimals: " # debug_show(decimals));
    return decimals;
  };

  // token total supply
  public shared({ caller }) func totalSupply(): async Nat {
    let totalSupply = await Icrc1Ledger.icrc1_total_supply();
    // show total supply
    Debug.print("Token Total Supply: " # debug_show(totalSupply));
    return totalSupply;
  };

  // token balance of
  public shared({ caller }) func balance_Of(account: Account): async Nat {    
    // Correctly create the object with owner and subaccount fields
    let accountObj = {
      owner = account.owner;
      subaccount = null;
    };
    let balance = await Icrc1Ledger.icrc1_balance_of(accountObj);
    // show balance
    Debug.print("Token Balance of " # Principal.toText(account.owner) # ": " # debug_show(balance));
    return balance;
  };

  public shared query (msg) func whoami() : async Principal {
    Debug.print("Caller: " # Principal.toText(msg.caller));
    msg.caller
  };

  public query ({caller}) func whoami2() : async Principal {
    Debug.print("Caller: " # Principal.toText(caller));
    return caller;
  };

  // s
}
