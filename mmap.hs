module Main where

import System.IO.MMap ( Mode(..), mmapFilePtr, munmapFilePtr )
import Data.ByteString.Internal ( fromForeignPtr )
import Data.ByteString.Char8 as BS
import Foreign.Concurrent ( newForeignPtr )

main :: IO ()
main = do
    (ptr, rawsize, offset, size) <- mmapFilePtr "banci.org" ReadOnly Nothing
    fptr <- newForeignPtr ptr (return ())
    let s = fromForeignPtr fptr offset size
    BS.putStrLn s
    munmapFilePtr ptr rawsize
