{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent
import Data.Monoid
import qualified SendFile
import SimpleRequestTest

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit

main :: IO ()
main = defaultMainWithOpts
       [ testCase "sendfile" testSendFile
       ] mempty

testSendFile :: Assertion
testSendFile = do
    _ <- forkIO SendFile.main
    testSimpleRequest