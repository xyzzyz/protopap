{-# LANGUAGE ConstraintKinds, ExistentialQuantification, TemplateHaskell #-}
module Network.RPC.Protopap.Subscriber where

import Network.RPC.Protopap.Types

import Control.Lens
import Control.Monad.IO.Class
import System.ZMQ4
import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

import qualified Data.Map as M

class MonadIO m => ZMQRPCSubscriber m where
  withSubSocket :: (Socket Sub -> m a) -> m a

data RPCSubHandler m = forall msg. RPCAppPubSub msg
                    => RPCSubHandler (msg -> m ())

type RawRPCSubHandler m = ByteString -> m (Either String ())

data RPCSubscriberDefinition m = RPCSubscriberDefinition {
  _messages :: M.Map String (RawRPCSubHandler m)
  }

$(makeLenses ''RPCSubscriberDefinition)

makeSubscriberDefinition :: ZMQRPCSubscriber m =>
                         [(String, RPCSubHandler m)] -> RPCSubscriberDefinition m
makeSubscriberDefinition messages =
  RPCSubscriberDefinition $ M.fromList (mapped._2 %~ makeRawHandler $ messages)

makeRawHandler :: ZMQRPCSubscriber m => RPCSubHandler m -> RawRPCSubHandler m
makeRawHandler (RPCSubHandler f) bs = do
  case messageGet bs of
    Left error_message ->
      return . Left $ "Failed to parse app request: " ++ error_message
    Right (appPub, extra) -> do
      f appPub
      return (Right ())
