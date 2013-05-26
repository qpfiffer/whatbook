module ParseMobi where

import System.IO

-- | The type created and returned by parseMobi.
data MobiInfo = MobiInfo { author :: String
                         , title :: String
                         } deriving (Eq, Show)

parseMobi :: FilePath -> Maybe MobiInfo
parseMobi _ = Just $ MobiInfo "Duke McQueen" "How I became the sun: Twelve Stories of Success"
