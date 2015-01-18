{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Network.RPC.Protopap.Proto.RPCRequest (RPCRequest(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
 
data RPCRequest = RPCRequest{method :: !(P'.Maybe P'.Utf8)}
                deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable RPCRequest where
  mergeAppend (RPCRequest x'1) (RPCRequest y'1) = RPCRequest (P'.mergeAppend x'1 y'1)
 
instance P'.Default RPCRequest where
  defaultValue = RPCRequest P'.defaultValue
 
instance P'.Wire RPCRequest where
  wireSize ft' self'@(RPCRequest x'1)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 9 x'1)
  wirePut ft' self'@(RPCRequest x'1)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutOpt 10 9 x'1
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{method = Prelude'.Just new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self
 
instance P'.MessageAPI msg' (msg' -> RPCRequest) RPCRequest where
  getVal m' f' = f' m'
 
instance P'.GPB RPCRequest
 
instance P'.ReflectDescriptor RPCRequest where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [10])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Network.RPC.Protopap.Proto.RPCRequest\", haskellPrefix = [], parentModule = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\"], baseName = MName \"RPCRequest\"}, descFilePath = [\"Network\",\"RPC\",\"Protopap\",\"Proto\",\"RPCRequest.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Network.RPC.Protopap.Proto.RPCRequest.method\", haskellPrefix' = [], parentModule' = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\",MName \"RPCRequest\"], baseName' = FName \"method\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}"
 
instance P'.TextType RPCRequest where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage
 
instance P'.TextMsg RPCRequest where
  textPut msg
   = do
       P'.tellT "method" (method msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'method]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'method
         = P'.try
            (do
               v <- P'.getT "method"
               Prelude'.return (\ o -> o{method = v}))