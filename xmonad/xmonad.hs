-- ~/.xmonad/xmonad.hs

import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Tabbed

main = xmonad =<< xmobar gnomeConfig { modMask = mod4Mask
                            , layoutHook = layoutHook gnomeConfig }
