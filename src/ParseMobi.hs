module ParseMobi where

import System.IO

-- Idea:
-- Go to offset 0x80 (128) to see if there is an EXTH header.
-- If there is one, go to 0xF4 + 0x04 (244 + 4) which is where the EXTH header should be.
-- Do a check to see if 'E X T H' are in those first 4 bytes
-- Move 4 bytes, read in header length (4 bytes)
-- Move 4 bytes, get number of records
-- Move 4 bytes, get the record type (100 = author, 
--
-- Or just check the first 31 bytes which will probably have the book title.
-- Looking for the EXTH header, and then 64 00 00 00 (A type of 'author') does pretty well.


-- | The type created and returned by parseMobi.
data MobiInfo = MobiInfo { author :: String
                         , title :: String
                         } deriving (Eq, Show)

parseMobi :: FilePath -> Maybe MobiInfo
parseMobi _ = Just $ MobiInfo "Duke McQueen" "How I became the sun: Twelve Stories of Success"
