{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent
import Data.Monoid
import qualified Naive
import SimpleRequestTest

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit

main :: IO ()
main = defaultMainWithOpts
       [ testCase "naive" testNaive
       ] mempty

testNaive :: Assertion
testNaive = do
    _ <- forkIO Naive.main
    testSimpleRequest