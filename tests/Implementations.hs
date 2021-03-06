module Implementations where

import qualified Control.Concurrent.Chan.Unagi as U
import qualified Control.Concurrent.Chan.Unagi.Unboxed as UU
import qualified Data.Primitive as P

type Implementation inc outc a = (IO (inc a, outc a), inc a -> a -> IO (), outc a -> IO a, inc a -> IO (outc a))

unagiImpl :: Implementation U.InChan U.OutChan a
unagiImpl =  (U.newChan, U.writeChan, U.readChan, U.dupChan)

unboxedUnagiImpl :: (P.Prim a)=> Implementation UU.InChan UU.OutChan a
unboxedUnagiImpl = (UU.newChan, UU.writeChan, UU.readChan, UU.dupChan)

