{-# LANGUAGE ConstraintKinds, FlexibleContexts #-}

module Network.RPC.Protopap.Client(makeRPCCall, rpcCall) where

import Network.RPC.Protopap.Types
import Network.RPC.Protopap.Proto.RPCRequest as RPCRequest
import Network.RPC.Protopap.Proto.RPCResponse as RPCResponse
import Network.RPC.Protopap.Proto.RPCResponse.Status as RPCResponse.Status

import Control.Exception.Lifted
import Control.Monad.Trans.Control

import Data.Maybe
import Data.ByteString.Lazy
import Data.ByteString.Lazy as ByteString
import Control.Applicative
import Control.Monad.IO.Class
import System.ZMQ4
import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

makeRPCCall :: (RPCAppRequest req, RPCAppResponse res, MonadIO m, MonadBaseControl IO m) =>
               String -> String -> req -> m (Either RPCCallError res)
makeRPCCall endpoint method appRequest = do
  bracket (create endpoint) destroy $ \(_, sock) -> rpcCall sock method appRequest
    where create endpoint = liftIO $ do
            ctx <- context
            sock <- socket ctx Req
            connect sock endpoint
            return (ctx, sock)
          destroy (ctx, sock) = liftIO $ do
            close sock
            term ctx

rpcCall :: (RPCAppRequest req, RPCAppResponse res, MonadIO m) =>
           Socket Req -> String -> req -> m (Either RPCCallError res)
rpcCall sock method appRequest = do
  let req = RPCRequest { method = Just (uFromString method) }
  liftIO $ send' sock [] (
    runPut $ messageWithLengthPutM req >> messageWithLengthPutM appRequest)
  bs <- liftIO (receive sock)
  case messageWithLengthGet . fromStrict $ bs of
    Left error_message ->
      return . Left . RPCError $ "Failed to parse proto response: " ++ error_message
    Right (rpcResponse, extraData) ->
      return $ handleRPCResponse rpcResponse extraData

handleRPCResponse :: RPCAppResponse res =>
                     RPCResponse -> ByteString -> Either RPCCallError res
handleRPCResponse rpcResponse extraData =
  case RPCResponse.status rpcResponse of
    Nothing ->
      Left (RPCError "RPC response contained no status")
    Just (RPCResponse.Status.RPC_ERROR) ->
      Left (RPCError status_info)
    Just (RPCResponse.Status.APP_ERROR) ->
      Left (AppError status_info)
    Just (RPCResponse.Status.OK) ->
      readAppResponse extraData
  where status_info = maybe "" uToString . RPCResponse.status_info $ rpcResponse


readAppResponse :: RPCAppResponse res => ByteString -> Either RPCCallError res
readAppResponse extraData = do
  case messageWithLengthGet extraData of
    Left error_message ->
      Left . RPCError $ "Failed to parse app response: " ++ error_message
    Right (appResponse, x) | not (ByteString.null x) ->
      Left . RPCError $ "App response message contained extra data."
    Right (appResponse, x) | ByteString.null x -> Right appResponse



