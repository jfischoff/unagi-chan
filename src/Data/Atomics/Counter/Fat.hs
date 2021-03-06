module Data.Atomics.Counter.Fat (
      AtomicCounter()
    , newCounter
    , incrCounter
    , readCounter
    ) where

-- An atomic counter padded with 64-bytes (an x86 cache line) on either side to
-- try to avoid false sharing.

import Data.Primitive.MachDeps(sIZEOF_INT)
import Control.Monad.Primitive(RealWorld)
import Data.Primitive.ByteArray
import Data.Atomics(fetchAddByteArrayInt)

newtype AtomicCounter = AtomicCounter (MutableByteArray RealWorld)

sIZEOF_CACHELINE , cACHELINE_PADDED_INT_IX  :: Int
sIZEOF_CACHELINE   = 64
cACHELINE_PADDED_INT_IX = (sIZEOF_CACHELINE `quot` 2) `quot` sIZEOF_INT

newCounter :: Int -> IO AtomicCounter
{-# INLINE newCounter #-}
newCounter n = do
    arr <- newAlignedPinnedByteArray 
                sIZEOF_CACHELINE
                sIZEOF_CACHELINE
    writeByteArray arr cACHELINE_PADDED_INT_IX n
    return (AtomicCounter arr)

incrCounter :: Int -> AtomicCounter -> IO Int
{-# INLINE incrCounter #-}
incrCounter incr (AtomicCounter arr) =
    fetchAddByteArrayInt arr cACHELINE_PADDED_INT_IX incr

readCounter :: AtomicCounter -> IO Int
{-# INLINE readCounter #-}
readCounter (AtomicCounter arr) = 
    readByteArray arr cACHELINE_PADDED_INT_IX
