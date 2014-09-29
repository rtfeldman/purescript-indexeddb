module IndexedDB where

import Data.Either
import Data.Function
import Control.Monad.Eff
import Control.Monad.Cont.Trans

type IDBName    = String
type IDBVersion = Number

foreign import data IDB            :: !
foreign import data IDBConnection  :: *
foreign import data IDBTransaction :: *
foreign import data IDBError       :: *

type WithIDB eff = Eff (idb :: IDB | eff)
type WithIDBCont eff = ContT Unit (WithIDB eff)

data IDBOpenResult =
    IDBFailure       IDBError
  | IDBUpgradeNeeded IDBConnection IDBTransaction

data StorageType = Temporary | Permanent

foreign import openIDBNative
  """
    function openIDBNative(dbName, version, storageType, onSuccess, onFailure, onUpgradeNeeded) {
      return function() {
        if (indexedDB) {
          var request;

          try {
            request = indexedDB.open(dbName, {version: version, storage: storageType});
          } catch (exception) {
            onFailure(exception);
          }

          request.onupgradeneeded = function(event) {
            onUpgradeNeeded(event.target.result, event.target.transaction);
          };

          request.onsuccess = function(event) {
            onSuccess(event.target.result);
          }

          request.onerror = function(error) {
            onFailure(error);
          }
        } else {
          onFailure(new Error("This environment does not support indexedDB."));
        }
      };
    }
  """
  :: forall eff. Fn6 IDBName IDBVersion StorageType -- TODO marshal StorageType correctly
    (IDBConnection -> Eff (idb :: IDB | eff) Unit)
    -- TODO convert these to useful types; upgrade needed and error are completely different!
    (IDBOpenResult -> Eff (idb :: IDB | eff) Unit)
    (IDBOpenResult -> Eff (idb :: IDB | eff) Unit)
    (                 Eff (idb :: IDB | eff) Unit)

openIDB :: forall eff. IDBName -> IDBVersion -> StorageType ->
  (Either IDBOpenResult IDBConnection -> WithIDB eff Unit) ->
  WithIDB eff Unit
openIDB name version storageType continuation = runFn6 openIDBNative
  name version storageType
  (continuation <<< Right)
  (continuation <<< Left)
  (continuation <<< Left)

openIDBCont :: forall eff. IDBName -> IDBVersion -> StorageType ->
  WithIDBCont eff (Either IDBOpenResult IDBConnection)
openIDBCont name version storageType = ContT $ openIDB name version storageType
