{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module ParseMobi where

import           Data.ByteString.Lazy as BL
import           Data.ByteString.Lazy.Char8 as BLC
import           Data.Binary
import           Data.Binary.Get
import           GHC.Generics (Generic)
-- Idea:
-- Go to offset 0x80 (128) to see if there is an EXTH header.
-- If there is one, go to 0xF4 + 0x04 (244 + 4) which is where the EXTH header
-- should be.
-- Do a check to see if 'E X T H' are in those first 4 bytes
-- Move 4 bytes, read in header length (4 bytes)
-- Move 4 bytes, get number of records
-- Move 4 bytes, get the record type (100 = author, 
--
-- Or just check the first 31 bytes which will probably have the book title.
-- Looking for the EXTH header, and then 64 00 00 00 (A type of 'author') does
-- pretty well.


-- | The type created and returned by parseMobi.
data MobiInfo = MobiInfo { author :: BL.ByteString
                         , title :: BL.ByteString
                         , filepath :: FilePath
                         , exth_offset :: ByteOffset
                         } deriving (Eq, Generic)

instance Binary MobiInfo

instance Show MobiInfo where
    show a = (BLC.unpack $ author a) ++ ", " ++ (BLC.unpack $ title a)

-- Pass in an opened mobi file, and this will return the offset of the
-- EXTH header.
findEXTHHeader :: BL.ByteString -> Maybe ByteOffset
findEXTHHeader "" = Nothing
findEXTHHeader file =
    -- Do something clever here.
  where
    read_func = runGet (getLazyByteString 4) file

-- Pass in an opened mobi file, and this will search for the EXTH header
-- and try to find the author in that file.
getAuthorFromFile :: BL.ByteString -> Maybe BL.ByteString
getAuthorFromFile "" = Nothing
getAuthorFromFile file = Just "N/A"
--runGet getRemainingLazyByteString file

-- | Pass in a filehandle and parseMobi will spit out (probably) a MobiInfo
-- thing.
parseMobi :: BL.ByteString -> FilePath -> Maybe MobiInfo
parseMobi file file_path =
    Just $ MobiInfo (BLC.pack $ show book_author) (BLC.pack $ show header) file_path 0
  where
    header = runGet getLazyByteStringNul file
    book_author = case getAuthorFromFile file of
        Nothing -> "N/A"
        (Just author_name) -> author_name
