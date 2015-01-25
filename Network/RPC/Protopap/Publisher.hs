{-# LANGUAGE ConstraintKinds #-}
module Network.RPC.Protopap.Publisher(rpcPublish) where

import Network.RPC.Protopap.Types
import Network.RPC.Protopap.Proto.RPCPubSub

import Control.Monad.IO.Class
import System.ZMQ4
import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

rpcPublish :: (MonadIO m, RPCAppPubSub pub) => Socket Pub -> String -> pub -> m ()
rpcPublish sock name msg = do
  let rpcMsg = RPCPubSub { message_type = Just . uFromString $ name }
      packet = runPut $ messageWithLengthPutM rpcMsg >> messageWithLengthPutM msg
  liftIO $ send' sock [] packet
