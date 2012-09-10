{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent
import Data.ByteString.Char8 ( ByteString )
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Data.Monoid
import qualified Naive
import Network.HTTP
import Network.URI

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit

main :: IO ()
main = defaultMainWithOpts
       [ testCase "naive" testNaive
       ] mempty

makeRequest :: String -> Request ByteString
makeRequest url =
    Request { rqURI = fromJust (parseURI url)
            , rqMethod = GET
            , rqHeaders = []
            , rqBody = "" }

testNaive :: Assertion
testNaive = do
    _ <- forkIO Naive.main
    res <- simpleHTTP (makeRequest "http://localhost:5000/Naive.hs")
    case res of
      Left err -> do
          error (show err)
      Right rsp -> do
          text <- BS.readFile "Naive.hs"
          rspBody rsp @?= text
