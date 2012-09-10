module Main where

import Network.Socket ( Socket, recv )
import Network.Socket.SendFile ( sendFile )
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
    sendFile socket (tail uri)  -- drop the leading '/'
