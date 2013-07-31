module Main where

import Control.Monad (liftM)
import System.Environment (getArgs, getProgName)
import System.IO (stderr, hPutStrLn)
import System.Process (system)

data Hdmi = HdmiOn | HdmiOff

{-| Return the shell commands to execute when turning HDMI on/off.
  Commands include extending the display with xrandr, and moving
  sound output to HDMI1.
 -}
hdmiCommands :: Hdmi -> [String]
hdmiCommands HdmiOn  = ["xrandr --output HDMI1 --auto --right-of LVDS1",
                        "pactl set-card-profile 0 output:hdmi-stereo"]
hdmiCommands HdmiOff = ["xrandr --output HDMI1 --off --right-of LVDS1",
                        "pactl set-card-profile 0 output:analog-stereo"]

{-| Read the command line parameter and return either a Maybe Hdmi
    if "on" or "off" are provided, and Nothing otherwise. -}
getHdmiFlag :: [String] -> Maybe Hdmi
getHdmiFlag ["on"]  = Just HdmiOn
getHdmiFlag ["off"] = Just HdmiOff
getHdmiFlag _       = Nothing


{-| Execute the given shell commands -}
-- TODO: See if it's possible to directly call the xrandr and pulseaudio
--       APIs instead of shelling out.
runCommands :: [String] -> IO ()
runCommands commands = mapM_ system commands


{-| Display a usage string -}
usage :: IO ()
usage = do
    prog <- getProgName
    hPutStrLn stderr $ "Usage: " ++ prog ++ " <on|off>"


main :: IO ()
main = do
  hdmiMaybe <- getHdmiFlag `liftM` getArgs
  maybe usage (runCommands . hdmiCommands) hdmiMaybe
