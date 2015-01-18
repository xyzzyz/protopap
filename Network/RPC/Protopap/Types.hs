module Network.RPC.Protopap.Types(RPCAppRequest, RPCAppResponse) where

import Text.ProtocolBuffers.Reflections
import Text.ProtocolBuffers.WireMessage

class (ReflectDescriptor req, Wire req) => RPCAppRequest req
class (ReflectDescriptor res, Wire res) => RPCAppResponse res
