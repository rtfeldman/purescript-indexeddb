module IDBStream where

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

type M eff = Eff (idb :: IDB | eff)
type C eff = ContT Unit (M eff)

data IDBOpenResult =
    IDBFailure       IDBError
  | IDBUpgradeNeeded IDBConnection IDBTransaction

foreign import openIDBNative
  """
    function openIDBNative(dbName, version, onSuccess, onFailure, onUpgradeNeeded) {
      return function() {
        if (indexedDB) {
          var request;

          try {
            request = indexedDB.open(dbName, version);
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
  :: forall eff. Fn5 IDBName IDBVersion
    (IDBConnection -> Eff (idb :: IDB | eff) Unit)
    -- TODO convert these to useful types; upgrade needed and error are completely different!
    (IDBOpenResult -> Eff (idb :: IDB | eff) Unit)
    (IDBOpenResult -> Eff (idb :: IDB | eff) Unit)
    (                 Eff (idb :: IDB | eff) Unit)

openIDB :: forall eff. IDBName -> IDBVersion ->
  (Either IDBOpenResult IDBConnection -> Eff (idb :: IDB | eff) Unit) -> Eff (idb :: IDB | eff) Unit
openIDB name version continuation = runFn5 openIDBNative
  name version
  (continuation <<< Right)
  (continuation <<< Left)
  (continuation <<< Left)

openIDBCont :: forall eff. IDBName -> IDBVersion ->
  C eff (Either IDBOpenResult IDBConnection)

openIDBCont name version = ContT $ openIDB name version
