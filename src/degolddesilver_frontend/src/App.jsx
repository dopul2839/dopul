import React, { useState, useEffect } from "react";
import { icrc1_ledger_canister_backend } from "declarations/icrc1_ledger_canister_backend";
import { Principal } from "@dfinity/principal";
import { idlFactory } from "declarations/icrc1_ledger_canister_backend";
import { AuthClient } from "@dfinity/auth-client";
import LoggedOut from "./LoggedOut";
import { useAuth, AuthProvider } from "./use-auth-client";
import "./assets/main.css";
import LoggedIn from "./LoggedIn";
import PlugConnection from "./PlugConnection";
import { Actor, HttpAgent } from "@dfinity/agent";

function App() {
  const { isAuthenticated } = useAuth();
  const [tokenName, setTokenName] = useState("");
  const [tokenSymbol, setTokenSymbol] = useState("");
  const [tokenDecimals, setTokenDecimals] = useState("");
  const [tokenTotalSupply, setTokenTotalSupply] = useState("");
  const [accountBalance, setAccountBalance] = useState("");
  const [userPrincipal, setUserPrincipal] = useState("");
  const [canprincipal, setCanprincipal] = useState("");
  const [loggedInPrincipal, setLoggedInPrincipal] = useState("");
  const [loggedInPrincipal2, setLoggedInPrincipal2] = useState("");
  const [plugPublicKey, setPlugPublicKey] = useState("");
  const [infinityWalletPublicKey, setInfinityWalletPublicKey] = useState("");
  const [infinityWalletPrincipal, setInfinityWalletPrincipal] = useState("");
  const [actor, setActor] = useState(null);
  const [transferAmount, setTransferAmount] = useState("");
  const [recipientPrincipal, setRecipientPrincipal] = useState("");

  // Handler for creating a new actor
  const createActor = async () => {
    console.log("env", process.env);

    let agent = new HttpAgent();
    if (process.env.DFX_NETWORK !== "ic") {
      agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Ensure that you're running the replica."
        );
        console.error(err);
      });
    }
    const newActor = Actor.createActor(idlFactory, {
      canisterId: process.env.CANISTER_ID_ICRC1_LEDGER_CANISTER_BACKEND,
      agent,
    });
    console.log(newActor);
    setActor(newActor);
  };

  // Handler for transferring tokens
  const transferTokens = async (event) => {
    event.preventDefault();
    if (!actor) {
      console.error("Actor is not created yet.");
      return;
    }
    try {
      const recipient = Principal.fromText(recipientPrincipal);
      const amount = BigInt(transferAmount) * BigInt(100000000); // Adjust for decimals
      const result = await actor.transfer2({
        toAccount: {
          owner: recipient,
          subaccount: [], // If subaccount is required, provide the correct value
        },
        amount: amount,
        toSubaccount: [], // If subaccount is required, provide the correct value
      });
      console.log("Transfer result:", result);
    } catch (error) {
      console.error("Error transferring tokens:", error);
    }
  };

  // Handler for fetching token name
  function fetchTokenName(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.name().then((tokenName) => {
      setTokenName(tokenName);
    });
  }

  // Handler for fetching token symbol
  function fetchTokenSymbol(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.symbol().then((tokenSymbol) => {
      setTokenSymbol(tokenSymbol);
    });
  }

  // Handler for fetching token decimals
  function fetchTokenDecimals(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.decimals().then((decimals) => {
      setTokenDecimals(decimals);
    });
  }

  // Handler for fetching token total supply
  function fetchTokenTotalSupply(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.totalSupply().then((tokenTotalSupply) => {
      var nattts = tokenTotalSupply.toString();
      console.log(nattts);
      var tts = parseInt(nattts);
      console.log(tts);
      var ttsby8 = tts / 100000000;
      console.log(ttsby8);
      setTokenTotalSupply(ttsby8.toString());
    });
  }

  // Handler for fetching account balance
  function fetchAccountBalance(event) {
    event.preventDefault();
    const principal = Principal.fromText(userPrincipal);
    icrc1_ledger_canister_backend
      .balance_Of({ owner: principal, subaccount: [] })
      .then((accountBalance) => {
        var nataccbal = accountBalance.toString();
        console.log(nataccbal);
        var accbal = parseInt(nataccbal);
        console.log(accbal);
        var accbalby8 = accbal / 100000000;
        console.log(accbalby8);
        setAccountBalance(accbalby8.toString());
      });
  }

  // Handler for updating userPrincipal state
  function handlePrincipalChange(event) {
    setUserPrincipal(event.target.value);
  }

  // Handler for getCanprincipal
  function fetchCanprincipal(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.getPrincipal().then((canprincipal) => {
      let canprincipal2 = Principal.from(canprincipal);
      setCanprincipal(canprincipal2.toText());
    });
  }

  // function fetchLoggedInPrincipal(event) {
  //   event.preventDefault();
  //   icrc1_ledger_canister_backend.whoami().then((loggedInPrincipal) => {
  //     let loggedInPrincipal2 = Principal.from(loggedInPrincipal);
  //     setLoggedInPrincipal(loggedInPrincipal2.toText());
  //   });
  // }

  // function fetchLoggedInPrincipal2(event) {
  //   event.preventDefault();
  //   icrc1_ledger_canister_backend.whoami2().then((loggedInPrincipal2) => {
  //     console.log(loggedInPrincipal2);
  //     console.log(loggedInPrincipal2.toText());
  //     setLoggedInPrincipal2(loggedInPrincipal2.toText());
  //   });
  // }
  // const handlePlugConnect = (plugPublicKey) => {
  //   console.log("Inside handlePlugConnect function");
  //   console.log("plugPublicKey", plugPublicKey);
  //   setPlugPublicKey(plugPublicKey);
  // };

  // // Handler for connecting to InfinityWallet
  // const connectToInfinityWallet = async () => {
  //   try {
  //     if (window.ic && window.ic.infinityWallet) {
  //       const publicKey = await window.ic?.infinityWallet?.requestConnect({
  //         whitelist: [
  //           "b77ix-eeaaa-aaaaa-qaada-cai",
  //           "bw4dl-smaaa-aaaaa-qaacq-cai",
  //           "be2us-64aaa-aaaaa-qaabq-cai",
  //           "bkyz2-fmaaa-aaaaa-qaaaq-cai",
  //           "br5f7-7uaaa-aaaaa-qaaca-cai",
  //         ], // Add your canister IDs here if needed
  //         timeout: 50000,
  //       });
  //       console.log(`The connected user's public key is:`, publicKey);
  //       setInfinityWalletPublicKey(publicKey);
  //     } else {
  //       console.log("InfinityWallet is not available");
  //     }
  //   } catch (e) {
  //     console.log(e);
  //   }
  // };

  // // Handler for fetching InfinityWallet Principal
  // const fetchInfinityWalletPrincipal = async () => {
  //   try {
  //     if (window.ic && window.ic.infinityWallet) {
  //       const principalId = await window.ic?.infinityWallet?.getPrincipal();
  //       console.log(`InfinityWallet's user principal Id is ${principalId}`);
  //       setInfinityWalletPrincipal(principalId);
  //     } else {
  //       console.log("InfinityWallet is not available");
  //     }
  //   } catch (e) {
  //     console.log(e);
  //   }
  // };

  // Handler for logging in using Internet Identity
  const useLogin = async () => {
    try {
      const authClient = await AuthClient.create();
      authClient.login({
        maxTimeToLive: BigInt(60 * 60 * 24 * 365 * 1000000000),
        onSuccess: async () => {
          handleAuthenticated(authClient);
        },
        identityProvider:
          process.env.DFX_NETWORK === "ic"
            ? "https://identity.ic0.app/#authorize"
            : `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`,
      });
      const handleAuthenticated = () => {
        console.log(
          "My principal is",
          authClient.getIdentity().getPrincipal().toString()
        );
      };
      const identity = await authClient.getIdentity();
      console.log(identity);
      console.log("My principal is", identity.getPrincipal().toString());
      const agent = new HttpAgent({ identity });
      if (process.env.DFX_NETWORK !== "ic") {
        agent.fetchRootKey().catch((err) => {
          console.warn(
            "Unable to fetch root key. Ensure that you're running the replica."
          );
          console.error(err);
        });
      }

      const actor = Actor.createActor(idlFactory, {
        agent,
        canisterId: process.env.CANISTER_ID_ICRC1_LEDGER_CANISTER_BACKEND,
      });
      let principal = await actor.getPrincipal();
      console.log(principal.toString());
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <>
      <header id="header">
        <section id="status" className="toast hidden">
          <span id="content"></span>
          <button className="close-button" type="button">
            <svg
              aria-hidden="true"
              className="w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fillRule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clipRule="evenodd"
              ></path>
            </svg>
          </button>
        </section>
      </header>
      <main id="pageContent">
        {/*Login button*/}
        <button onClick={useLogin}>Login</button>
        {/*Logout button*/}
        <button onClick={createActor}>Create Actor</button>{" "}
        {/* Add button to create actor */}
        {/* <PlugConnection onConnect={handlePlugConnect} />
        {isAuthenticated ? <LoggedIn /> : <LoggedOut />} */}
        <img
          src="/DGoldSilverLogo.png"
          alt="DGold DSilver logo"
          className="logo-image"
        />
        <br />
        <br />
        <br />
        <br />
        <button onClick={fetchTokenName}>Fetch Token Name</button>
        <section id="tokenName">Token Name: {tokenName}</section>
        <br />
        <button onClick={fetchTokenSymbol}>Fetch Token Symbol</button>
        <section id="tokenSymbol">Token Symbol: {tokenSymbol}</section>
        <br />
        <button onClick={fetchTokenDecimals}>Fetch Token Decimals</button>
        <section id="tokenDecimals">Token Decimals: {tokenDecimals}</section>
        <br />
        <button onClick={fetchTokenTotalSupply}>
          Fetch Token Total Supply
        </button>
        <section id="tokenTotalSupply">
          Token Total Supply: {tokenTotalSupply}
        </section>
        <br />
        <form action="#" onSubmit={fetchAccountBalance}>
          <label htmlFor="principal">Enter your principal: &nbsp;</label>
          <input
            id="userprincipal"
            alt="userPrincipal"
            type="text"
            onChange={handlePrincipalChange}
          />
          <button type="submit">Fetch Account Balance</button>
        </form>
        <section id="accountBalance">Account Balance: {accountBalance}</section>
        <br />
        <button onClick={fetchCanprincipal}>Fetch Canister Principal</button>
        <section id="canprincipal">Canister Principal: {canprincipal}</section>
        <br />
        {/* <br />
        <button onClick={fetchLoggedInPrincipal}>
          Fetch Logged In Principal
        </button>
        <section id="loggedInPrincipal">
          Logged In Principal: {loggedInPrincipal}
        </section>
        <br />
        <br />
        <button onClick={fetchLoggedInPrincipal2}>
          Fetch Logged In Principal 2
        </button>
        <section id="loggedInPrincipal2">
          Logged In Principal: {loggedInPrincipal2}
        </section>
        <br />
        <button onClick={connectToInfinityWallet}>
          Connect to InfinityWallet
        </button>
        <section id="infinityWalletPublicKey">
          InfinityWallet Public Key: {infinityWalletPublicKey}
        </section>
        <br />
        <button onClick={fetchInfinityWalletPrincipal}>
          Fetch InfinityWallet Principal
        </button>
        <section id="infinityWalletPrincipal">
          InfinityWallet Principal: {infinityWalletPrincipal}
        </section>
        <br /> */}
        {"\n"}
        <form action="#" onSubmit={transferTokens}>
          <></>
          <label htmlFor="recipientPrincipal">
            Recipient Principal: &nbsp;
          </label>
          <input
            id="recipientPrincipal"
            alt="recipientPrincipal"
            type="text"
            onChange={(e) => setRecipientPrincipal(e.target.value)}
          />
          {"\n"}

          <label htmlFor="transferAmount">Amount to Transfer: &nbsp;</label>

          <input
            id="transferAmount"
            alt="transferAmount"
            type="number"
            onChange={(e) => setTransferAmount(e.target.value)}
          />
          <button type="submit">Transfer Tokens</button>
        </form>
      </main>
    </>
  );
}

export default () => (
  <AuthProvider>
    <App />
  </AuthProvider>
);
