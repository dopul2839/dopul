import React, { useState, useEffect } from "react";
import { icrc1_ledger_canister_backend } from "declarations/icrc1_ledger_canister_backend";
import { Principal } from "@dfinity/principal";
import { AuthClient } from "@dfinity/auth-client";

import React from "react";
import LoggedOut from "./LoggedOut";
import { useAuth, AuthProvider } from "./use-auth-client";
import "./assets/main.css";
import LoggedIn from "./LoggedIn";
import PlugConnection from "./PlugConnection";

function App() {
  const { isAuthenticated, identity } = useAuth();
  const [tokenName, setTokenName] = useState("");
  const [tokenSymbol, setTokenSymbol] = useState("");
  const [tokenDecimals, setTokenDecimals] = useState("");
  const [tokenTotalSupply, setTokenTotalSupply] = useState("");
  const [accountBalance, setAccountBalance] = useState("");
  const [userPrincipal, setUserPrincipal] = useState("");
  const [canprincipal, setCanprincipal] = useState("");
  const [loggedInPrincipal, setLoggedInPrincipal] = useState("");
  const [loggedInPrincipal2, setLoggedInPrincipal2] = useState("");

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
      setCanprincipal(canprincipal.toText());
    });
  }

  function fetchLoggedInPrincipal(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.whoami().then((loggedInPrincipal) => {
      console.log(loggedInPrincipal);
      console.log(loggedInPrincipal.toString());
      setLoggedInPrincipal(loggedInPrincipal.toString());
    });
  }

  function fetchLoggedInPrincipal2(event) {
    event.preventDefault();
    icrc1_ledger_canister_backend.whoami2().then((loggedInPrincipal2) => {
      console.log(loggedInPrincipal2);
      console.log(loggedInPrincipal2.toText());
      setLoggedInPrincipal2(loggedInPrincipal2.toText());
    });
  }

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
        {isAuthenticated ? <LoggedIn /> : <LoggedOut />}
        <img src="/logo2.svg" alt="DFINITY logo" />
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
        <br />
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
      </main>
    </>
  );
}

export default () => (
  <AuthProvider>
    <App />
  </AuthProvider>
);
