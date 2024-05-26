import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Types "./Types";
import Icrc1Ledger "canister:icrc1_ledger_canister_backend";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";



shared actor class DGSuNFT(custodian: Principal, init : Types.Dip721NonFungibleToken) = Self {
  stable var transactionId: Types.TransactionId = 0;
  stable var goldNfts = List.nil<Types.GoldNft>();
  stable var silverNfts = List.nil<Types.SilverNft>();
  stable var validators = List.nil<Types.Validator>();
  stable var custodians = List.make<Principal>(custodian);
  stable var logo : Types.LogoResult = init.logo;
  stable var name : Text = init.name;
  stable var symbol : Text = init.symbol;
  stable var maxLimit : Nat16 = init.maxLimit;

  // Reserves
  stable var UGoldg: Nat = 0;
  stable var USilverg: Nat = 0;

  // Individual Reserves
  let UGoldgInd = HashMap.HashMap<Principal, Nat>(50, Principal.equal, Principal.hash);
  let USilvergInd = HashMap.HashMap<Principal, Nat>(50, Principal.equal, Principal.hash);

  let null_address : Principal = Principal.fromText("aaaaa-aa");

  public shared({ caller }) func mintGoldNFT(to: Principal, metadata: Types.MetadataDesc, weight: Nat, purity: Text): async Types.MintReceipt {
    if (not List.some(validators, func(val: Types.Validator): Bool { val.id == caller })) {
      return #Err(#Unauthorized);
    };

    let newId = Nat64.fromNat(List.size(goldNfts));
    let goldNft: Types.GoldNft = {
      owner = to;
      id = newId;
      metadata = metadata;
      weight = weight;
      purity = purity;
      validator = caller;
    };

    goldNfts := List.push(goldNft, goldNfts);
    transactionId += 1;
    UGoldg += weight; // Update UGoldg

    // Update individual gold reserve
    switch (UGoldgInd.get(to)) {
      case (null) {
        UGoldgInd.put(to, weight);
        Debug.print("User Gold Reserve: " # Nat.toText(weight));
      };
      case (?val) {
        UGoldgInd.put(to, val + weight);
        Debug.print("User Gold Reserve: " # Nat.toText(val + weight));
      };
    };

    // Mint DGSu tokens for the validator and user
    let validatorReward = 10_000_000_000;
    let userReward = 20_000_000_000;
    let mintValidatorResult = await Icrc1Ledger.mintTokens(caller, validatorReward);
    switch (mintValidatorResult) {
      case (#err(e)) { return #Err(#Other); };
      case (#ok(_)) {};
    };
    let mintUserResult = await Icrc1Ledger.mintTokens(to, userReward);
    switch (mintUserResult) {
      case (#err(e)) { return #Err(#Other); };
      case (#ok(_)) {};
    };

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller }) func mintSilverNFT(to: Principal, metadata: Types.MetadataDesc, weight: Nat, purity: Text): async Types.MintReceipt {
    if (not List.some(validators, func(val: Types.Validator): Bool { val.id == caller })) {
      return #Err(#Unauthorized);
    };

    let newId = Nat64.fromNat(List.size(silverNfts));
    let silverNft: Types.SilverNft = {
      owner = to;
      id = newId;
      metadata = metadata;
      weight = weight;
      purity = purity;
      validator = caller;
    };

    silverNfts := List.push(silverNft, silverNfts);
    transactionId += 1;
    USilverg += weight; // Update USilverg

    // Update individual Silver reserve
    switch (USilvergInd.get(to)) {
      case (null) {
        USilvergInd.put(to, weight);
        Debug.print("User Silver Reserve: " # Nat.toText(weight));
      };
      case (?val) {
        USilvergInd.put(to, val + weight);
        Debug.print("User Silver Reserve: " # Nat.toText(val + weight));
      };
    };

    // Mint DGSu tokens for the validator and user
    let validatorReward = 9_331_000_000;
    let userReward = 6_221_000_000;
    let mintValidatorResult = await Icrc1Ledger.mintTokens(caller, validatorReward);
    switch (mintValidatorResult) {
      case (#err(e)) { return #Err(#Other); };
      case (#ok(_)) {};
    };
    let mintUserResult = await Icrc1Ledger.mintTokens(to, userReward);
    switch (mintUserResult) {
      case (#err(e)) { return #Err(#Other); };
      case (#ok(_)) {};
    };

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

  public shared({ caller = _ }) func transferGoldNFT(from: Principal, to: Principal, token_id: Types.TokenId, caller: Principal) : async Types.TxReceipt {
    // Check if user has enough DGSu balance
    let fromaccount: Icrc1Ledger.Account = { owner = from; subaccount = null };
    let frombalance = await Icrc1Ledger.balance_Of(fromaccount);
    let minimumBalance: Nat = 500_000_000_000;
    if (frombalance < minimumBalance) {
      return #Err(#InsufficientBalance);
    };
    let toaccount: Icrc1Ledger.Account = { owner = to; subaccount = null };
    let tobalance = await Icrc1Ledger.balance_Of(toaccount);
    if (tobalance < minimumBalance) {
      return #Err(#InsufficientBalance);
    };

    // Transfer DGSu tokens with the NFT transfer - Gold - 

    let item = List.find(goldNfts, func(token: Types.GoldNft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        if (
          caller != token.owner and
          not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller })
        ) {
          return #Err(#Unauthorized);
        } else if (Principal.notEqual(from, token.owner)) {
          return #Err(#Other);
        } else {
          goldNfts := List.map(goldNfts, func (item : Types.GoldNft) : Types.GoldNft {
            if (item.id == token.id) {
              let update : Types.GoldNft = {
                owner = to;
                id = item.id;
                metadata = token.metadata;
                weight = item.weight;
                purity = item.purity;
                validator = item.validator;
              };
              return update;
            } else {
              return item;
            };
          });
          transactionId += 1;

          // Update individual gold reserves
          switch (UGoldgInd.get(from)) {
            case (?val) {
              UGoldgInd.put(from, val - token.weight);
            };
            case null {};
          };
          switch (UGoldgInd.get(to)) {
            case (?val) {
              UGoldgInd.put(to, val + token.weight);
            };
            case null {
              UGoldgInd.put(to, token.weight);
            };
          };

          return #Ok(transactionId);   
        };
      };
    };
  };

  func transferSilverNFT(from: Principal, to: Principal, token_id: Types.TokenId, caller: Principal) : async Types.TxReceipt {
    // Check if user has enough DGSu balance
    let fromaccount: Icrc1Ledger.Account = { owner = from; subaccount = null };
    let frombalance = await Icrc1Ledger.balance_Of(fromaccount);
    let minimumBalance: Nat = 500_000_000_000;
    if (frombalance < minimumBalance) {
      return #Err(#InsufficientBalance);
    };
    let toaccount: Icrc1Ledger.Account = { owner = to; subaccount = null };
    let tobalance = await Icrc1Ledger.balance_Of(toaccount);
    if (tobalance < minimumBalance) {
      return #Err(#InsufficientBalance);
    };

    let item = List.find(silverNfts, func(token: Types.SilverNft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        if (
          caller != token.owner and
          not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller })
        ) {
          return #Err(#Unauthorized);
        } else if (Principal.notEqual(from, token.owner)) {
          return #Err(#Other);
        } else {
          silverNfts := List.map(silverNfts, func (item : Types.SilverNft) : Types.SilverNft {
            if (item.id == token.id) {
              let update : Types.SilverNft = {
                owner = to;
                id = item.id;
                metadata = token.metadata;
                weight = item.weight;
                purity = item.purity;
                validator = item.validator;
              };
              return update;
            } else {
              return item;
            };
          });
          transactionId += 1;

          // Update individual silver reserves
          switch (USilvergInd.get(from)) {
            case (?val) {
              USilvergInd.put(from, val - token.weight);
            };
            case null {};
          };
          switch (USilvergInd.get(to)) {
            case (?val) {
              USilvergInd.put(to, val + token.weight);
            };
            case null {
              USilvergInd.put(to, token.weight);
            };
          };

          return #Ok(transactionId);   
        };
      };
    };
  };


  public shared({ caller }) func addValidator(id: Principal, name: Text) : async Bool {
    let validator : Types.Validator = {
      id = id;
      name = name;
    };

    validators := List.push(validator, validators);
    return true;
  };

  public query func getValidators() : async [Types.Validator] {
    return List.toArray(validators);
  };

  public query func getGoldNFTMetadata(token_id: Types.TokenId): async Types.GoldNftMetadataResult {
    let item = List.find(goldNfts, func(token: Types.GoldNft): Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok({
          metadata_desc = token.metadata;
          weight = token.weight;
          purity = token.purity;
        });
      };
    };
  };

  public query func getSilverNFTMetadata(token_id: Types.TokenId): async Types.SilverNftMetadataResult {
    let item = List.find(silverNfts, func(token: Types.SilverNft): Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok({
          metadata_desc = token.metadata;
          weight = token.weight;
          purity = token.purity;
        });
      };
    };
  };

  public query func logodet() : async Types.LogoResult {
    return logo;
  };

  public query func namedet() : async Text {
    return name;
  };

  public query func symboldet() : async Text {
    return symbol;
  };

  public query func totalSupplydet() : async Nat64 {
    return Nat64.fromNat(List.size(goldNfts) + List.size(silverNfts));
  };

  public query func getRGoldg() : async Nat {
    return UGoldg;
  };

  public query func getRSilverg() : async Nat {
    return USilverg;
  };

  public query func balanceOfGoldNFT(user: Principal): async Nat64 {
    return Nat64.fromNat(
      List.size(
        List.filter(goldNfts, func(token: Types.GoldNft): Bool { token.owner == user })
      )
    );
  };

  public query func balanceOfSilverNFT(user: Principal): async Nat64 {
    return Nat64.fromNat(
      List.size(
        List.filter(silverNfts, func(token: Types.SilverNft): Bool { token.owner == user })
      )
    );
  };

  public query func getIndividualGoldg(user: Principal): async Nat {
    switch (UGoldgInd.get(user)) {
      case (null) {
        let totaluserweight = 0;
        Debug.print("User Gold Reserve(null): " # Nat.toText(totaluserweight));
        return totaluserweight;
      };
      case (?val) {
        let totaluserweight = val;
        
        Debug.print("User Gold Reserve(val): " # Nat.toText(val));
        return totaluserweight;
      };
    };
  };

  // public query func getIndividualSilverg(user: Principal): async Nat {
  //   return USilvergInd.get(user) :? Nat;
  // };

  

}
