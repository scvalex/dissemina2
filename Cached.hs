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
module Main where

import Control.Concurrent.MVar ( MVar, newMVar, modifyMVar )
import Data.ByteString.Char8 ( ByteString )
import qualified Data.ByteString.Char8 as BS
import Data.Map ( Map )
import qualified Data.Map as M
import Network.Socket ( Socket )
import Network.Socket.ByteString ( sendAll )
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
              fileText <- BS.readFile uri
              return (M.insert uri fileText cache, fileText)
          Just fileText -> do
              return (cache, fileText)
    sendAll sock text
