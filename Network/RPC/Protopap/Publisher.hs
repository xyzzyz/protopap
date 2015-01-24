{-# LANGUAGE ConstraintKinds #-}
module Network.RPC.Protopap.Publisher where

import Network.RPC.Protopap.Types
import Network.RPC.Protopap.Proto.RPCPubSub

import Control.Monad.IO.Class
import System.ZMQ4
import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

class MonadIO m => ZMQRPCPublisher m where
  withPubSocket :: (Socket Pub -> m a) -> m a

rpcPublish :: (ZMQRPCPublisher m, RPCAppPubSub pub) => String -> pub -> m ()
rpcPublish name msg = withPubSocket $ \sock -> do
  let rpcMsg = RPCPubSub { message_type = Just . uFromString $ name }
  liftIO $ send' sock [] (runPut $ messagePutM rpcMsg >> messagePutM msg)
