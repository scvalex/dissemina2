-- | A simple fileserver written in the naïve way:
--
--  - receive and parse the incoming request,
--
--  - read the requested file's contents as a 'ByteString', and
--
--  - send the contents.
--
module Main where

import qualified Data.ByteString.Char8 as BS
import Network.Socket ( Socket )
import Network.Socket.ByteString ( sendAll )
import Utils ( runAcceptLoop, bindPort, readRequestUri )

main :: IO ()
main = do
    lsocket <- bindPort 5000
    runAcceptLoop lsocket handleRequest

handleRequest :: Socket -> IO ()
handleRequest sock = do
    uri <- readRequestUri sock
    text <- BS.readFile uri
    sendAll sock text
