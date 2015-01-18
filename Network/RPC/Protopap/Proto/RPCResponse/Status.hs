{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Network.RPC.Protopap.Proto.RPCResponse.Status (Status(..)) where
import Prelude ((+), (/), (.))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
 
data Status = OK
            | RPC_ERROR
            | APP_ERROR
            deriving (Prelude'.Read, Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable Status
 
instance Prelude'.Bounded Status where
  minBound = OK
  maxBound = APP_ERROR
 
instance P'.Default Status where
  defaultValue = OK
 
toMaybe'Enum :: Prelude'.Int -> P'.Maybe Status
toMaybe'Enum 1 = Prelude'.Just OK
toMaybe'Enum 2 = Prelude'.Just RPC_ERROR
toMaybe'Enum 3 = Prelude'.Just APP_ERROR
toMaybe'Enum _ = Prelude'.Nothing
 
instance Prelude'.Enum Status where
  fromEnum OK = 1
  fromEnum RPC_ERROR = 2
  fromEnum APP_ERROR = 3
  toEnum
   = P'.fromMaybe (Prelude'.error "hprotoc generated code: toEnum failure for type Network.RPC.Protopap.Proto.RPCResponse.Status") .
      toMaybe'Enum
  succ OK = RPC_ERROR
  succ RPC_ERROR = APP_ERROR
  succ _ = Prelude'.error "hprotoc generated code: succ failure for type Network.RPC.Protopap.Proto.RPCResponse.Status"
  pred RPC_ERROR = OK
  pred APP_ERROR = RPC_ERROR
  pred _ = Prelude'.error "hprotoc generated code: pred failure for type Network.RPC.Protopap.Proto.RPCResponse.Status"
 
instance P'.Wire Status where
  wireSize ft' enum = P'.wireSize ft' (Prelude'.fromEnum enum)
  wirePut ft' enum = P'.wirePut ft' (Prelude'.fromEnum enum)
  wireGet 14 = P'.wireGetEnum toMaybe'Enum
  wireGet ft' = P'.wireGetErr ft'
  wireGetPacked 14 = P'.wireGetPackedEnum toMaybe'Enum
  wireGetPacked ft' = P'.wireGetErr ft'
 
instance P'.GPB Status
 
instance P'.MessageAPI msg' (msg' -> Status) Status where
  getVal m' f' = f' m'
 
instance P'.ReflectEnum Status where
  reflectEnum = [(1, "OK", OK), (2, "RPC_ERROR", RPC_ERROR), (3, "APP_ERROR", APP_ERROR)]
  reflectEnumInfo _
   = P'.EnumInfo
      (P'.makePNF (P'.pack ".Network.RPC.Protopap.Proto.RPCResponse.Status") []
        ["Network", "RPC", "Protopap", "Proto", "RPCResponse"]
        "Status")
      ["Network", "RPC", "Protopap", "Proto", "RPCResponse", "Status.hs"]
      [(1, "OK"), (2, "RPC_ERROR"), (3, "APP_ERROR")]
 
instance P'.TextType Status where
  tellT = P'.tellShow
  getT = P'.getRead