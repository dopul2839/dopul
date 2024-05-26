import React, { useEffect, useState } from "react";

const PlugConnection = ({ onConnect }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [publicKey, setPublicKey] = useState("");

  const nnsCanisterId = "bw4dl-smaaa-aaaaa-qaacq-cai";
  const whitelist = [nnsCanisterId];
  const host = "b77ix-eeaaa-aaaaa-qaada-cai.localhost:4943";
  const onConnectionUpdate = () => {
    console.log(window.ic.plug.sessionManager.sessionData);
    // principal
    console.log(window.ic.plug.principalId);
  };

  const connectToPlug = async () => {
    try {
      const publicKey = await window.ic?.plug?.requestConnect({
        whitelist,
        host,
        onConnectionUpdate,
        timeout: 50000,
      });
      setPublicKey(publicKey);
      setIsConnected(true);
      console.log(`The connected user's public key is:`, publicKey);
      if (onConnect) {
        onConnect(publicKey);
      }
    } catch (e) {
      console.log(e);
    }
  };

  const verifyConnection = async () => {
    console.log("Verifying connection to Plug");
    const connected = await window.ic?.plug?.isConnected();
    if (!connected) {
      console.log("Not connected to Plug");
      await window.ic.plug.requestConnect({ whitelist, host });
    } else {
      console.log("Connected to Plug");
      setIsConnected(true);
    }
  };

  useEffect(() => {
    console.log("Checking connection to Plug");
    // verifyConnection();
  }, []);

  return (
    <div>
      {isConnected ? (
        <div>
          <p>Connected to Plug!</p>
          <p>Public Key: {publicKey}</p>
        </div>
      ) : (
        <button onClick={connectToPlug}>Connect to Plug</button>
      )}
    </div>
  );
};

export default PlugConnection;
