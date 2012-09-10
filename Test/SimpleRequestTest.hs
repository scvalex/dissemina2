{-# LANGUAGE OverloadedStrings #-}

module SimpleRequestTest where

import Data.ByteString.Char8 ( ByteString )
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Network.HTTP
import Network.URI

import Test.HUnit

makeRequest :: String -> Request ByteString
makeRequest url =
    Request { rqURI = fromJust (parseURI url)
            , rqMethod = GET
            , rqHeaders = []
            , rqBody = "" }

testSimpleRequest :: Assertion
testSimpleRequest = do
    res <- simpleHTTP (makeRequest "http://localhost:5000/Naive.hs")
    case res of
      Left err -> do
          error (show err)
      Right rsp -> do
          text <- BS.readFile "Naive.hs"
          rspBody rsp @?= text
