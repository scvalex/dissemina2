{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent
import Data.Monoid
import qualified Cached
import SimpleRequestTest

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit

main :: IO ()
main = defaultMainWithOpts
       [ testCase "cached" testCached
       ] mempty

testCached :: Assertion
testCached = do
    _ <- forkIO Cached.main
    testSimpleRequest