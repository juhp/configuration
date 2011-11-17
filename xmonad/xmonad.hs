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
--import XMonad.Layout.PositionStoreFloat
--import XMonad.Layout.WindowSwitcherDecoration

--import XMonad.Actions.BluetileCommands
import XMonad.Actions.CycleWS
import XMonad.Actions.FindEmptyWorkspace
import XMonad.Actions.Promote
--import XMonad.Actions.WindowMenu

--import XMonad.Hooks.CurrentWorkspaceOnTop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
--import XMonad.Hooks.PositionStoreHooks
import XMonad.Hooks.RestoreMinimized
import XMonad.Hooks.ServerMode
import XMonad.Hooks.WorkspaceByPos

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

--bluetileWorkspaces :: [String]
--bluetileWorkspaces = ["1".."9"]

changeBacklight = "xbacklight -time 20 -steps 2 "

bluetileMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
bluetileMouseBindings (XConfig {XMonad.modMask = modMask'}) = M.fromList $
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

bluetileManageHook :: ManageHook
bluetileManageHook = composeAll
               [ workspaceByPos
                , className =? "MPlayer" --> doFloat
                , manageDocks]

layout =  desktopLayoutModifiers $ noBorders Full ||| tiled ||| Mirror tiled
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
--          manageHook = bluetileManageHook,
          layoutHook = layout,
          handleEventHook = ewmhDesktopsEventHook
                                `mappend` restoreMinimizedEventHook,
--          workspaces = bluetileWorkspaces,
--          keys = bluetileKeys,
          keys = \cfg -> mkKeymap cfg (myKeymap cfg),
          mouseBindings = bluetileMouseBindings,
          focusFollowsMouse  = True,
          focusedBorderColor = "#ff5500",
          terminal = "gnome-terminal"
        }
  where

mykeys c = mkKeymap c (myKeymap c)
myKeymap c = 
           [ ("M-e", viewEmptyWorkspace)
           , ("S-M-e", tagToEmptyWorkspace)
           , ("S-M-k", kill)
           , ("S-M-l", spawn "gnome-screensaver-command -l")
           , ("M-m", windows W.focusMaster)
           , ("M-n", refresh)
           , ("M-q", restart "xmonad" True)
           , ("S-M-q", io (exitWith ExitSuccess))
           , ("M-x", spawn "gmrun")
           , ("<XF86MonBrightnessDown>", spawn "xbacklight -10")
           , ("<XF86MonBrightnessUp>", spawn "xbacklight +10")
           , ("M-<Tab>", windows W.focusDown)
           , ("M-S-<Tab>", windows W.focusUp)
           , ("M-<Return>", spawn $ terminal c)
           , ("M-<Space>", sendMessage NextLayout)
           , ("M-S-<Space>", setLayout $ XMonad.layoutHook c)
           , ("M-<Down>", withFocused $ windows . W.sink)
           , ("M-<Up>", withFocused $ windows . (\w -> W.float w (W.RationalRect 0.4 0.4 0.6 0.6)))
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

main = do
   dbusSess <- connectSession
   xmonad myConfig { logHook = ewmhDesktopsLogHook `mappend` dbusLog dbusSess defaultPP }
