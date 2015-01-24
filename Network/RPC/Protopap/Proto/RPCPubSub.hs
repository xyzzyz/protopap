{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Network.RPC.Protopap.Proto.RPCPubSub (RPCPubSub(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
 
data RPCPubSub = RPCPubSub{message_type :: !(P'.Maybe P'.Utf8)}
               deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable RPCPubSub where
  mergeAppend (RPCPubSub x'1) (RPCPubSub y'1) = RPCPubSub (P'.mergeAppend x'1 y'1)
 
instance P'.Default RPCPubSub where
  defaultValue = RPCPubSub P'.defaultValue
 
instance P'.Wire RPCPubSub where
  wireSize ft' self'@(RPCPubSub x'1)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeOpt 1 9 x'1)
  wirePut ft' self'@(RPCPubSub x'1)
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
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{message_type = Prelude'.Just new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self
 
instance P'.MessageAPI msg' (msg' -> RPCPubSub) RPCPubSub where
  getVal m' f' = f' m'
 
instance P'.GPB RPCPubSub
 
instance P'.ReflectDescriptor RPCPubSub where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList []) (P'.fromDistinctAscList [10])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Network.RPC.Protopap.Proto.RPCPubSub\", haskellPrefix = [], parentModule = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\"], baseName = MName \"RPCPubSub\"}, descFilePath = [\"Network\",\"RPC\",\"Protopap\",\"Proto\",\"RPCPubSub.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Network.RPC.Protopap.Proto.RPCPubSub.message_type\", haskellPrefix' = [], parentModule' = [MName \"Network\",MName \"RPC\",MName \"Protopap\",MName \"Proto\",MName \"RPCPubSub\"], baseName' = FName \"message_type\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}"
 
instance P'.TextType RPCPubSub where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage
 
instance P'.TextMsg RPCPubSub where
  textPut msg
   = do
       P'.tellT "message_type" (message_type msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'message_type]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'message_type
         = P'.try
            (do
               v <- P'.getT "message_type"
               Prelude'.return (\ o -> o{message_type = v}))