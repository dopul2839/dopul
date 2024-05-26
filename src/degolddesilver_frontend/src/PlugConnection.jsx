import React, { useEffect, useState } from "react";

const PlugConnection = ({ onConnect }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [publicKey, setPublicKey] = useState("");

  const nnsCanisterId = "qoctq-giaaa-aaaaa-aaaea-cai"; // Example canister ID
  const whitelist = [nnsCanisterId];
  const host = "https://mainnet.dfinity.network";

  const connectToPlug = async () => {
    try {
      const publicKey = await window.ic.plug.requestConnect({
        whitelist,
        host,
        onConnectionUpdate: () => {
          console.log(window.ic.plug.sessionManager.sessionData);
        },
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
    const connected = await window.ic.plug.isConnected();
    if (!connected) {
      await connectToPlug();
    } else {
      setIsConnected(true);
    }
  };

  useEffect(() => {
    verifyConnection();
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
