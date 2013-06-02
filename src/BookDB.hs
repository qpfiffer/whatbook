{-# LANGUAGE OverloadedStrings #-}

module BookDB where

import qualified Data.ByteString as BS
import           Database.KyotoCabinet.Db
import           System.FilePath.Find


initDB :: IO ()
initDB = do
    -- Kind of weird, but the KyotoCabinet DB bindings I am using determine
    -- the database type via the suffix.
    kcwithdbopen "books.kct" [] [KCOWRITER, KCOCREATE] $ \db -> do
        -- 1. Find all .mobi files
        -- 2. Parse the mobi itself and add the serialized MobiInfo object to
        -- the db
        -- 3. Cleanup
        mobi_files <- find always (extension ==? ".mobi"
            ||? extension ==? ".MOBI") "./"
        mapM_ putStrLn mobi_files
