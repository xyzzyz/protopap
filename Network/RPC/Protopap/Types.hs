{-# LANGUAGE ConstraintKinds #-}


module Network.RPC.Protopap.Types(RPCAppRequest, RPCAppResponse,
                                  RPCCallError(..)) where

import Text.ProtocolBuffers.Reflections
import Text.ProtocolBuffers.WireMessage

type RPCAppRequest req = (ReflectDescriptor req, Wire req) 
type RPCAppResponse res = (ReflectDescriptor res, Wire res) 

data RPCCallError = RPCError String | AppError String
