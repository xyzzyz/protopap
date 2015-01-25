{-# LANGUAGE ConstraintKinds, ExistentialQuantification, TemplateHaskell #-}
module Network.RPC.Protopap.Subscriber where

import Network.RPC.Protopap.Types
import Network.RPC.Protopap.Proto.RPCPubSub as RPCPubSub

import qualified Data.ByteString.Lazy as BS
import Control.Applicative
import Control.Lens
import Control.Monad.IO.Class
import System.ZMQ4
import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

import qualified Data.Map as M

data RPCSubHandler m a = forall msg. RPCAppPubSub msg =>
                         RPCSubHandler (msg -> m a)

type RawRPCSubHandler m a = ByteString -> m (Either String a)

data RPCSubscriberDefinition m a = RPCSubscriberDefinition {
  _messages :: M.Map String (RawRPCSubHandler m a)
  }

$(makeLenses ''RPCSubscriberDefinition)

makeSubscriberDefinition :: Monad m =>
                         [(String, RPCSubHandler m a)] -> RPCSubscriberDefinition m a
makeSubscriberDefinition messages =
  RPCSubscriberDefinition $ M.fromList (mapped._2 %~ makeRawHandler $ messages)

makeRawHandler :: Monad m => RPCSubHandler m a -> RawRPCSubHandler m a
makeRawHandler (RPCSubHandler f) bs = do
  case messageWithLengthGet bs of
    Left error_message ->
      return . Left $ "Failed to parse app request: " ++ error_message
    Right (appPub, extra) -> do
      a <- f appPub
      return $ Right a


rpcHandleSubsciption :: MonadIO m => RPCSubscriberDefinition m a -> Socket Sub
                        -> m (Either String a)
rpcHandleSubsciption subDef sock = do
  bs <- liftIO (receive sock)
  case messageWithLengthGet . BS.fromStrict $ bs of
    Left err -> return $ Left err
    Right (rpcPubSub, extraData) ->
      handleRPCPubSub subDef sock rpcPubSub extraData

handleRPCPubSub subDef sock rpcPubSub extra = do
  case message_type rpcPubSub of
    Nothing -> return $ Left "no message type in RPCPubSub"
    Just message_type -> case subDef^.messages.to (M.lookup (uToString message_type)) of
      Nothing -> return $ Left ("unknown message type: " ++ show message_type)
      Just f -> f extra

