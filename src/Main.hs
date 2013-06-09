{-# LANGUAGE OverloadedStrings #-}

import BookDB
import Data.ByteString.Lazy.Char8 as BS
import System.Environment
import System.Exit

printUsage :: IO ()
printUsage = do
    BS.putStrLn "potential-octo-shame [COMMAND]"
    BS.putStrLn "Available commands:"
    BS.putStrLn "help                   -- Displays this text."
    BS.putStrLn "init                   -- Initializes the database."
    BS.putStrLn "dump                   -- Dumps all the records in the database."
    BS.putStrLn "update                 -- Updates the database."
    BS.putStrLn "search_title <title>   -- Searches the database for books titled <title>."
    BS.putStrLn "search_author <author> -- Searches the database for books written by  <author>."
    exitWith ExitSuccess

searchTitle :: BS.ByteString -> BS.ByteString
searchTitle term_title = BS.concat ["Did not find ", term_title, " when searching for author."]

searchAuthor :: BS.ByteString -> BS.ByteString
searchAuthor term_author = BS.concat ["Did not find ", term_author, " when searching for author."]

runCommand :: [BS.ByteString] -> IO ()
runCommand ["help"] = printUsage
runCommand ["search_title", term_title] = BS.putStrLn $
    searchTitle term_title
runCommand ["search_author", term_author] = BS.putStrLn $
    searchAuthor term_author
runCommand ["init"] = do
    BS.putStrLn "Initializing books.kch..."
    initDB
    BS.putStrLn "Finished updating books db."
runCommand ["dump"] = do
    BS.putStrLn "Dumping DB..."
    dumpDB
    BS.putStrLn "Dumped all records."
runCommand _ = printUsage

main :: IO ()
main = do
    args <- getArgs
    runCommand $ fmap BS.pack args

    exitWith ExitSuccess

