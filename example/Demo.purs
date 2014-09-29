module Demo where

import IndexedDB
import Control.Monad.Eff

import Debug.Trace

main = do
  trace "Initializing IndexedDB..."

  return unit