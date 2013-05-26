{-# LANGUAGE OverloadedStrings #-}

import Data.ByteString.Char8 as BS
import Database.KyotoCabinet.Db as KC

import Prelude hiding (putStrLn)

printUsage :: IO ()
printUsage = do
    putStrLn "whatbook [COMMAND]"
    putStrLn "Available commands:"
    putStrLn "help                   -- Displays this text."
    putStrLn "init                   -- Initializes the database."
    putStrLn "update                 -- Updates the database."
    putStrLn "search_title <title>   -- Searches the database for books titled <title>."
    putStrLn "search_author <author> -- Searches the database for books written by  <author>."

main :: IO ()
main = do
    printUsage

