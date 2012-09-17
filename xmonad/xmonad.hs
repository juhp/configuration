import XMonad hiding ( (|||) )
import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.BorderResize
import XMonad.Layout.BoringWindows
import XMonad.Layout.ButtonDecoration
import XMonad.Layout.Decoration
import XMonad.Layout.DecorationAddons
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.TwoPane
import XMonad.Layout.PositionStoreFloat
import XMonad.Layout.WindowSwitcherDecoration

import XMonad.Actions.CycleWS
import XMonad.Actions.FindEmptyWorkspace
import XMonad.Actions.GroupNavigation
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Promote
--import XMonad.Actions.RotSlaves
--import XMonad.Actions.WindowMenu

import XMonad.Config.Bluetile
import XMonad.Config.Gnome (gnomeRun)

--import XMonad.Hooks.CurrentWorkspaceOnTop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
--import XMonad.Hooks.FloatNext
import XMonad.Hooks.ManageDocks (avoidStruts)
--import XMonad.Hooks.PositionStoreHooks
import XMonad.Hooks.RestoreMinimized
import XMonad.Hooks.ServerMode
--import XMonad.Hooks.WorkspaceByPos

import XMonad.Prompt
import XMonad.Prompt.Window

import XMonad.Util.EZConfig
--import XMonad.Util.Replace
--import XMonad.Util.Scratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import System.Exit
import Data.Monoid
import Control.Monad(when)


myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modMask'}) = M.fromList $
    [
    -- mod-button2 %! Switch to next and first layout
      ((modMask', button2), (\_ -> sendMessage NextLayout))
    , ((modMask' .|. shiftMask, button2), (\_ -> sendMessage $ JumpToLayout "Floating"))
    ]

isFloating :: Window -> X (Bool)
isFloating w = do
    ws <- gets windowset
    return $ M.member w (W.floating ws)

bluetileLayout = avoidStruts $ minimize $ boringWindows $ (
                                        named "Floating" floating |||
                                        named "Tiled1" tiled1 |||
                                        named "Tiled2" tiled2 |||
                                        named "Fullscreen" fullscreen
                                        )
        where
            floating = floatingDeco $ maximize $ borderResize $ positionStoreFloat
            tiled1 = tilingDeco $ maximize $ mouseResizableTile { isMirrored = True }
            tiled2 = tilingDeco $ maximize $ mouseResizableTile
            fullscreen = tilingDeco $ maximize $ smartBorders Full
            tilingDeco l = windowSwitcherDecorationWithButtons shrinkText bluetileTheme (draggingVisualizer l)
            floatingDeco l = buttonDeco shrinkText bluetileTheme l
            bluetileTheme = defaultThemeWithButtons { activeColor = "SteelBlue3"
                                                    , activeTextColor = "white"
                                                    , activeBorderColor = "SteelBlue2"
                                                    , inactiveColor = "gray88"
                                                    , inactiveTextColor = "black"
                                                    , inactiveBorderColor = "gray84"
                                                    , fontName = "xft:Sans:size=11"
                                                    }

myConfig =
    bluetileConfig
        { layoutHook = bluetileLayout,
          logHook = logHook bluetileConfig <+> historyHook,
          keys = \cfg -> mkKeymap cfg (myKeymap cfg),
          mouseBindings = myMouseBindings,
          focusedBorderColor = "darkgray",
          normalBorderColor = "gray"
        }

spawnEmpty cmd = viewEmptyWorkspace >> spawn cmd

myKeymap c =
           [ ("M-a", sendMessage $ JumpToLayout "Floating")
           , ("M-s", sendMessage $ JumpToLayout "Tiled1")
           , ("M-d", sendMessage $ JumpToLayout "Tiled2")
           , ("M-f", sendMessage $ JumpToLayout "Fullscreen")
           , ("M-z", withFocused (sendMessage . maximizeRestore))
           , ("M-b", nextMatchOrDo History (className =? "Google-chrome") (spawnEmpty "google-chrome"))
           , ("M-c", nextMatchOrDo History (className =? "Xchat-gnome") (spawnEmpty "xchat-gnome"))
           , ("M-e", nextMatchOrDo History (className =? "Emacs") (spawnEmpty "emacs"))
           , ("M-t", nextMatchOrDo History (className =? "Gnome-terminal") (spawnEmpty "gnome-terminal"))
           , ("M-S-t", spawn $ terminal c)
           , ("M-v", nextMatchOrDo History (className =? "Virt-manager") (spawnEmpty "virt-manager"))
           , ("M-m", nextMatchOrDo History (className =? "Firefox") (spawnEmpty "firefox"))
           , ("M-g", gnomeRun)
           , ("M-S-k", kill)
           , ("M-l", nextMatch History (return True))
           , ("M-S-l", spawn "xflock4")
           , ("M-n", viewEmptyWorkspace)
           , ("M-S-n", tagToEmptyWorkspace)
           , ("M-q", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage \"xmonad not found!\"; fi")
--           , ("M-S-q", io (exitWith ExitSuccess))
           , ("M-r", refresh)
           , ("M-w", windowPromptGoto defaultXPConfig)
           , ("M-x", spawn "gmrun")
           , ("M-S-x", spawnEmpty "gmrun")
           , ("M-<Tab>", windows W.focusDown)
           , ("M-S-<Tab>", nextMatchWithThis Forward className)
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
           ++
           [(m ++ "M-" ++ key, f sc)
                |  (key, sc) <- zip ["<Up>", "<Down>"] [0..]
                , (f, m) <- [(viewScreen, ""), (sendToScreen, "S-")]]

main = xmonad myConfig
