{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BookDB where

import           ParseMobi
import           Control.Exception
import           Data.Binary as B
import qualified Data.ByteString.Lazy as BL
import           Data.ByteString.Lazy.Char8 as BLC
import           Database.KyotoCabinet.Db
import           System.FilePath.Find as F

import           Prelude hiding (catch)


addFile :: FilePath -> KcDb -> IO ()
addFile file db = do
    opened_file <- BL.readFile file
    -- TODO: file does not need to be passed in here.
    case parseMobi opened_file file of
        Nothing -> BLC.putStrLn "Could not add file."
        Just parsed -> do
            BLC.putStrLn $ BL.concat ["Adding ", title parsed]
            kcdbset db (BL.toStrict $ title parsed) (BL.toStrict $
                B.encode parsed)

initDB :: IO ()
initDB = do
    -- Kind of weird, but the KyotoCabinet DB bindings I am using determine
    -- the database type via the suffix.
    kcwithdbopen "books.kct" [] [KCOWRITER, KCOCREATE] $ \db -> do
        -- Find all of the mobi files in this directory
        mobi_files <- F.find always (extension ==? ".mobi"
            ||? extension ==? ".MOBI") "./"
        -- Add them to the datbase
        mapM_ (\x -> addFile x db)  mobi_files

dumpDB :: IO ()
dumpDB = do
    kcwithdbopen "books.kct" [] [KCOWRITER, KCOCREATE] $ \db -> do
        kcwithdbcursor db $ \cur -> do
            kccurjump cur
            let loop = do
                (key, val) <- kccurget cur True
                Prelude.putStrLn $ show key ++ " : " ++ show (B.decode $ BLC.fromStrict val :: MobiInfo)
                loop
            loop `catch` \(_::KcException) -> return ()
