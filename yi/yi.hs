import Yi

-- Preamble
import Yi.Prelude
import Prelude ()

-- Import the desired keymap "template":
import Yi.Keymap.Emacs (keymap)
-- import Yi.Keymap.Cua (keymap)
-- import Yi.Keymap.Vim (keymapSet)

import Yi.Hoogle (hoogle)

-- Import the desired UI as needed. 
-- Some are not complied in, so we import none here.

-- import Yi.UI.Vty (start)
-- import Yi.UI.Cocoa (start)
-- import Yi.UI.Pango (start)

myConfig = defaultEmacsConfig -- replace with defaultVimConfig or defaultCuaConfig

-- Change the below to your needs, following the explanation in comments. See
-- module Yi.Config for more information on configuration. Other configuration
-- examples can be found in the examples directory. You can also use or copy
-- another user configuration, which can be found in modules Yi.Users.*

main :: IO ()
main = yi $ myConfig
