{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Network.RPC.Protopap.Proto.RPCResponse (RPCResponse(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Network.RPC.Protopap.Proto.RPCResponse.Status as Network.RPC.Protopap.Proto.RPCResponse (Status)
 
data RPCResponse = RPCResponse{status :: !(P'.Maybe Network.RPC.Protopap.Proto.RPCResponse.Status),
                               status_info :: !(P'.Maybe P'.Utf8)}
                 deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable RPCResponse where
  mergeAppend (RPCResponse x'1 x'2) (RPCResponse y'1 y'2) = RPCResponse (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2)
 
instance P'.Default RPCResponse where
  defaultValue = RPCResponse P'.defaultValue P'.defaultValue
 
instance P'.Wire RPCResponse where
  wireSize ft' self'@(RPCResponse x'1 x'2)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 14 x'1 + P'.wireSizeOpt 1 9 x'2)
  wirePut ft' self'@(RPCResponse x'1 x'2)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutOpt 8 14 x'1
             P'.wirePutOpt 18 9 x'2
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             8 -> Prelude'.fmap (\ !new'Field -> old'Self{status = Prelude'.Just new'Field}) (P'.wireGet 14)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{status_info = Prelude'.Just new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self
 
instance P'.MessageAPI msg' (msg' -> RPCResponse) RPCResponse where
  getVal m' f' = f' m'
 
instance P'.GPB RPCResponse
 
instance P'.ReflectDescriptor RPCResponse where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [8, 18])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Network.RPC.Protopap.Proto.RPCResponse\", haskellPrefix = [], parentModule = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\"], baseName = MName \"RPCResponse\"}, descFilePath = [\"Network\",\"RPC\",\"Protopap\",\"Proto\",\"RPCResponse.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Network.RPC.Protopap.Proto.RPCResponse.status\", haskellPrefix' = [], parentModule' = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\",MName \"RPCResponse\"], baseName' = FName \"status\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 14}, typeName = Just (ProtoName {protobufName = FIName \".Network.RPC.Protopap.Proto.RPCResponse.Status\", haskellPrefix = [], parentModule = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\",MName \"RPCResponse\"], baseName = MName \"Status\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Network.RPC.Protopap.Proto.RPCResponse.status_info\", haskellPrefix' = [], parentModule' = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\",MName \"RPCResponse\"], baseName' = FName \"status_info\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}"
 
instance P'.TextType RPCResponse where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage
 
instance P'.TextMsg RPCResponse where
  textPut msg
   = do
       P'.tellT "status" (status msg)
       P'.tellT "status_info" (status_info msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'status, parse'status_info]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'status
         = P'.try
            (do
               v <- P'.getT "status"
               Prelude'.return (\ o -> o{status = v}))
        parse'status_info
         = P'.try
            (do
               v <- P'.getT "status_info"
               Prelude'.return (\ o -> o{status_info = v}))