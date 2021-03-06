module Utils (
        runAcceptLoop, bindPort, readRequestUri
    ) where

import Control.Monad ( forever )
import Control.Concurrent ( forkIO )
import Control.Exception ( bracketOnError, finally )
import Network.Socket ( Socket, socket, sClose
                      , Family(..), SocketType(..)
                      , AddrInfo(..), AddrInfoFlag(..), getAddrInfo
                      , defaultHints, defaultProtocol, maxListenQueue
                      , accept, bindSocket, listen, recv
                      , SocketOption(..), setSocketOption )

-- | Accept connections on the given socket and spawn a new handler
-- for each.  Close the socket even if the handler throws an
-- exception.
runAcceptLoop :: Socket -> (Socket -> IO ()) -> IO ()
runAcceptLoop lsocket handler = forever $ do
    (sock, _addr) <- accept lsocket
    _ <- forkIO $ finally (handler sock) (sClose sock)
    return ()

-- | Create a socket and bind it to the given port.
bindPort :: Int -> IO Socket
bindPort port = do
    addrInfos <- getAddrInfo
                     (Just (defaultHints { addrFlags = [AI_PASSIVE]
                                         , addrFamily = AF_INET }))
                     Nothing (Just (show port))
    let addr = head addrInfos
    bracketOnError
        (socket (addrFamily addr) Stream defaultProtocol)
        sClose
        (\sock -> do
             setSocketOption sock ReuseAddr 1
             bindSocket sock (addrAddress addr)
             listen sock maxListenQueue
             return sock)

-- | Read an HTTP request and return its uri.  Fails if the request
-- isn't a @GET@ method, or if the client is too slow in sending the
-- request.  Does no sanitisation of the request (i.e. a malicious
-- client could request arbitrary files from the filesystem).
readRequestUri :: Socket -> IO FilePath
readRequestUri sock = do
    -- FIXME Do a better job of reading the request's first line.
    requestLine <- recv sock 1024
    let ("GET" : uri : _) = words requestLine
    return ('.' : uri)
