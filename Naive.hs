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
import Network.Socket ( Socket, recv )
import Network.Socket.ByteString ( sendAll )
import Utils ( runAcceptLoop, bindPort )

main :: IO ()
main = do
    lsocket <- bindPort 5000
    runAcceptLoop lsocket handleRequest

handleRequest :: Socket -> IO ()
handleRequest socket = do
    -- FIXME This should be a loop to handle partial receives.
    requestLine <- recv socket 1024
    let ("GET" : uri : _) = words requestLine
    text <- BS.readFile ('.' : uri)
    sendAll socket text
