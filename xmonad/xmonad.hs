import XMonad hiding ( (|||) )
import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.BorderResize
import XMonad.Layout.BoringWindows
--import XMonad.Layout.ButtonDecoration
import XMonad.Layout.Decoration
--import XMonad.Layout.DecorationAddons
--import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.TwoPane
--import XMonad.Layout.PositionStoreFloat
--import XMonad.Layout.WindowSwitcherDecoration

--import XMonad.Actions.BluetileCommands
import XMonad.Actions.CycleWS
--import XMonad.Actions.FindEmptyWorkspace
import XMonad.Actions.GroupNavigation
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Promote
--import XMonad.Actions.RotSlaves
--import XMonad.Actions.WindowMenu

--import XMonad.Hooks.CurrentWorkspaceOnTop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FloatNext
import XMonad.Hooks.ManageDocks
--import XMonad.Hooks.PositionStoreHooks
import XMonad.Hooks.RestoreMinimized
import XMonad.Hooks.ServerMode
--import XMonad.Hooks.WorkspaceByPos

import XMonad.Config.Desktop

import XMonad.Util.EZConfig
--import XMonad.Util.Replace
--import XMonad.Util.Scratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import System.Exit
import Data.Monoid
import Control.Monad(when)

import DBus.Client.Simple
import System.Taffybar.XMonadLog (dbusLog)
import Web.Encodings (encodeHtml)


changeBacklight = "xbacklight -time 20 -steps 2 "

myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modMask'}) = M.fromList $
    -- mod-button1 %! Move a floated window by dragging
    [ ((modMask', button1), (\w -> isFloating w >>= \isF -> when (isF) $
                                focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    -- mod-button2 %! Switch to next and first layout
    , ((modMask', button2), (\_ -> sendMessage NextLayout))
    , ((modMask' .|. shiftMask, button2), (\_ -> sendMessage $ JumpToLayout "Floating"))
    -- mod-button3 %! Resize a floated window by dragging
    , ((modMask', button3), (\w -> isFloating w >>= \isF -> when (isF) $
                                focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    ]

isFloating :: Window -> X (Bool)
isFloating w = do
    ws <- gets windowset
    return $ M.member w (W.floating ws)

layout =  desktopLayoutModifiers $ noBorders Full ||| TwoPane (3/100) (1/2) ||| tiled ||| Mirror tiled
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myConfig =
    desktopConfig
        { modMask = mod4Mask,   -- logo key
          manageHook = floatNextHook <+> manageDocks,
          layoutHook = layout,
          logHook = ewmhDesktopsLogHook <+> historyHook,
          handleEventHook = ewmhDesktopsEventHook
                                `mappend` restoreMinimizedEventHook,
--          workspaces = ["1".."9"],
          keys = \cfg -> mkKeymap cfg (myKeymap cfg),
          mouseBindings = myMouseBindings,
          focusFollowsMouse  = True,
          focusedBorderColor = "#ff5500",
          terminal = "gnome-terminal"
        }

myKeymap c =
           [ ("M-b", nextMatchOrDo History (className =? "Google-chrome") (spawn "google-chrome"))
           , ("M-c", nextMatchOrDo History (className =? "Xchat-gnome") (spawn "xchat-gnome"))
           , ("M-e", nextMatchOrDo History (className =? "Emacs") (spawn "emacs"))
           , ("M-t", nextMatchOrDo History (className =? "Gnome-terminal") (spawn "gnome-terminal"))
           , ("M-v", nextMatchOrDo History (className =? "Virt-manager") (spawn "virt-manager"))
           , ("M-f", withFocused $ windows . (\w -> W.float w (W.RationalRect 0.4 0.4 0.6 0.6)))
           , ("M-S-f", withFocused $ windows . W.sink)
           , ("M-S-k", kill)
           , ("M-l", nextMatch History (return True))
           , ("M-S-l", spawn "xflock4")
           , ("M-m", windows W.focusMaster)
           , ("M-n", refresh)
           , ("M-q", spawn "xmonad --recompile; xmonad --restart")
           , ("M-S-q", io (exitWith ExitSuccess))
           , ("M-u", floatNext True)
           , ("M-x", spawn "gmrun")
           , ("M-S-x", spawn "xfce4-appfinder")
           , ("<XF86MonBrightnessDown>", spawn "xbacklight -10")
           , ("<XF86MonBrightnessUp>", spawn "xbacklight +10")
           , ("M-<Tab>", nextMatchWithThis Forward className)
           , ("M-S-<Tab>", windows W.focusDown)
           , ("M-<Return>", spawn $ terminal c)
           , ("M-<Space>", sendMessage NextLayout)
           , ("M-S-<Space>", setLayout $ XMonad.layoutHook c)
           , ("M--", sendMessage Shrink)
           , ("M-=", sendMessage Expand)
           , ("M-S--", sendMessage (IncMasterN (-1))) -- %! Decrement the number of windows in the master area
           , ("M-S-=", sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
           ]
           ++
           [(m ++ "M-<F" ++ show n ++ ">", windows $ f w)
                | (w, n) <- zip (XMonad.workspaces c) [1..9]
           , (f, m) <- [(W.view, ""), (W.shift, "S-")]]
--           ++
--           [("M-" ++ show (n+1) , focusNth n) | n <- [0..8]]
           ++
           [(m ++ "M-" ++ key, f sc)
                |  (key, sc) <- zip ["<Up>", "<Down>"] [0..]
                , (f, m) <- [(viewScreen, ""), (sendToScreen, "S-")]]

taffyPP = defaultPP { ppCurrent = wrap "<span foreground=\"red\">" "</span>"
                    , ppTitle = (wrap "<b>" "</b>") . encodeHtml  . shorten 90 }


main = do
   dbusSess <- connectSession
   xmonad myConfig { logHook = logHook myConfig <+> dbusLog dbusSess taffyPP }
