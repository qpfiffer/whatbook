{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BookDB where

import           ParseMobi
import           Control.Exception
import           Data.Binary as B
import           Data.ByteString.Lazy as BL
import           Data.ByteString.Lazy.Char8 as BLC
import           Database.KyotoCabinet.Db
import           System.FilePath.Find as F

import           Prelude hiding (catch)


addFile :: FilePath -> KcDb -> IO ()
addFile file db = do
    opened_file <- BL.readFile file
    case parseMobi opened_file of
        Nothing -> BLC.putStrLn "Could not add file."
        Just parsed -> do
            BLC.putStrLn $ BL.concat ["Adding ", title parsed]
            kcdbset db (BL.toStrict $ title parsed) (BL.toStrict $ B.encode parsed)

initDB :: IO ()
initDB = do
    -- Kind of weird, but the KyotoCabinet DB bindings I am using determine
    -- the database type via the suffix.
    kcwithdbopen "books.kct" [] [KCOWRITER, KCOCREATE] $ \db -> do
        -- 1. Find all .mobi files
        -- 2. Parse the mobi itself and add the serialized MobiInfo object to
        -- the db
        -- 3. Cleanup
        mobi_files <- F.find always (extension ==? ".mobi"
            ||? extension ==? ".MOBI") "./"
        mapM_ (\x -> addFile x db)  mobi_files

dumpDB :: IO ()
dumpDB = do
    kcwithdbopen "books.kct" [] [KCOWRITER, KCOCREATE] $ \db -> do
        kcwithdbcursor db $ \cur -> do
            kccurjump cur
            let loop = do
                (key, val) <- kccurget cur True
                BLC.putStrLn $ BL.concat [BL.fromStrict key, " : ", BL.fromStrict val]
                loop
            loop `catch` \(exn::KcException) -> return ()
