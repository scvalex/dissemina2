{-# LANGUAGE OverloadedStrings #-}

-- | A simple fileserver that uses the @sendfile(2)@ system call:
--
--  - receive and parse the incoming request, and
--
--  - @sendfile@ the requested file.
--
module Main where

import Data.ByteString.Char8 ()
import Network.Socket ( Socket )
import Network.Socket.ByteString ( sendAll )
import Network.Socket.SendFile ( sendFile )
import Utils ( runAcceptLoop, bindPort, readRequestUri )

main :: IO ()
main = do
    lsocket <- bindPort 5000
    runAcceptLoop lsocket handleRequest

handleRequest :: Socket -> IO ()
handleRequest sock = do
    uri <- readRequestUri sock
    sendAll sock "HTTP/1.1 200 OK\r\n\r\n"
    sendFile sock uri
