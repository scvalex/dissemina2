{-# LANGUAGE OverloadedStrings #-}

-- | A simple fileserver with caching:
--
--  - receive and parse the incoming request,
--
--  - if the requested file is in the cache, read the cached contents,
--
--  - otherwise, read the requested file's contents as a 'ByteString',
--  insert it into the cache, and
--
--  - send the contents.
--
-- Rather than handling cache expiry ourselves, we @mmap(2)@ the file
-- to memory.  This way, the OS is responsible for swapping the file
-- in and out of memory, and Haskell's garbage collector is
-- responsible for unmmaping the file when it's no longer needed.
--
module Cached where

import Control.Concurrent.MVar ( MVar, newMVar, modifyMVar )
import Data.ByteString.Char8 ( ByteString )
import Data.Map ( Map )
import qualified Data.Map as M
import Network.Socket ( Socket )
import Network.Socket.ByteString ( sendAll )
import System.IO.MMap ( mmapFileByteString )
import Utils ( runAcceptLoop, bindPort, readRequestUri )

main :: IO ()
main = do
    lsocket <- bindPort 5000
    cache <- newMVar M.empty
    runAcceptLoop lsocket (handleRequest cache)

handleRequest :: MVar (Map String ByteString) -> Socket -> IO ()
handleRequest cacheVar sock = do
    text <- modifyMVar cacheVar $ \cache -> do
        uri <- readRequestUri sock
        case M.lookup uri cache of
          Nothing -> do
              -- fileText <- readFile uri
              fileText <- mmapFileByteString uri Nothing
              return (M.insert uri fileText cache, fileText)
          Just fileText -> do
              return (cache, fileText)
    sendAll sock "HTTP/1.1 200 OK\r\n\r\n"
    sendAll sock text
