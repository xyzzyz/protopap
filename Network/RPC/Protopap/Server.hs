{-# LANGUAGE ConstraintKinds, RankNTypes, ImpredicativeTypes, GeneralizedNewtypeDeriving, ExistentialQuantification, TemplateHaskell #-}

module Network.RPC.Protopap.Server where
import Network.RPC.Protopap.Types

import Network.RPC.Protopap.Proto.RPCRequest as RPCRequest
import Network.RPC.Protopap.Proto.RPCResponse as RPCResponse
import Network.RPC.Protopap.Proto.RPCResponse.Status as RPCResponse.Status

import Data.Monoid
import qualified Data.ByteString.Lazy as BS
import Control.Applicative
import Control.Lens
import Control.Monad.IO.Class
import System.ZMQ4

import Text.ProtocolBuffers.Basic
import Text.ProtocolBuffers.WireMessage

import qualified Data.Map as M

data RPCHandler m = forall req res. (RPCAppRequest req, RPCAppResponse res)
                    => RPCHandler (req -> m (Either String res))
type RawRPCHandler m = ByteString -> m (Either RPCCallError Put)

data RPCServiceDefinition m = RPCServiceDefinition {
  _methods :: M.Map String (RawRPCHandler m)
  }

$(makeLenses ''RPCServiceDefinition)

makeServiceDefinition :: Monad m => [(String, RPCHandler m)] -> RPCServiceDefinition m
makeServiceDefinition methods =
  RPCServiceDefinition $ M.fromList (mapped._2 %~ makeRawHandler $ methods)

makeRawHandler :: Monad m => RPCHandler m -> RawRPCHandler m
makeRawHandler (RPCHandler f) bs = do
  case messageWithLengthGet bs of
    Left errorMessage ->
      return . Left . RPCError $ "Failed to parse app request: " ++ errorMessage
    Right (appRequest, extra) -> do
      res <- f appRequest
      case res of
        Left err -> return . Left . AppError $ err
        Right appResponse -> return . Right . messageWithLengthPutM $ appResponse


requestParseError message = RPCResponse {
  status = Just RPCResponse.Status.RPC_ERROR,
  status_info = Just . uFromString $ "Couldn't parse RPC request proto: " ++ message }

noMethodProviderError = RPCResponse {
  status = Just RPCResponse.Status.RPC_ERROR,
  status_info = Just . uFromString $ "RPC request didn't contain RPC method" }

noSuchMethodError name = RPCResponse {
  status = Just RPCResponse.Status.RPC_ERROR,
  status_info = Just . uFromString $ "No such RPC method: " <> name }

appError err = RPCResponse {
  status = Just RPCResponse.Status.APP_ERROR,
  status_info = Just . uFromString $ err }

okResponse = RPCResponse {
  status = Just RPCResponse.Status.OK,
  status_info = Nothing
  }

sendRPCErrorResponse :: MonadIO m => Socket Rep -> RPCResponse -> m ()
sendRPCErrorResponse sock res = liftIO $ send' sock [] (messagePut res)

handleRPCCall :: MonadIO m => RPCServiceDefinition m -> Socket Rep -> m ()
handleRPCCall serviceDef sock = do
  bs <- liftIO (receive sock)
  case messageWithLengthGet . BS.fromStrict $ bs of
    Left errorMessage ->
      sendRPCErrorResponse sock (requestParseError errorMessage)
    Right (rpcRequest, extraData) ->
      handleRPCRequest serviceDef sock rpcRequest extraData

handleRPCRequest serviceDef sock request appRequestData =
  case getHandlerFunction request of
    Left err -> sendRPCErrorResponse sock err
    Right f -> do
      res <- f appRequestData
      case res of
        Left (AppError err) -> sendRPCErrorResponse sock (appError err)
        Right appResponse ->
          liftIO . send' sock [] . runPut $ (
            messageWithLengthPutM okResponse >> appResponse)
  where getHandlerFunction request = do
          name <- maybe (Left noMethodProviderError) (Right . uToString)
                  (method request)
          maybe (Left . noSuchMethodError $ name) Right $
            serviceDef^.methods.to (M.lookup name)

