import System.Environment
import System.Directory
import System.FilePath.Find
 
search pat dir = find always (fileName ~~? pat) dir
main = search "*.gpg" "/Users/oren/.password-store" >>= mapM_ putStrLn
 
-- main = do [pat] <- getArgs
--           dir   <- getCurrentDirectory
--           files <- search "*.gpg" "/Users/oren/.password-store"
--           mapM_ putStrLn files


