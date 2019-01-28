
      _____   _____ _____ _____   _               _____    _______ _____ __  __ ______ _____
     |  __ \ / ____/ ____|_   _| | |        /\   |  __ \  |__   __|_   _|  \/  |  ____|  __ \
     | |__) | (___| (___   | |   | |       /  \  | |__) |    | |    | | | \  / | |__  | |__) |
     |  _  / \___ \\___ \  | |   | |      / /\ \ |  ___/     | |    | | | |\/| |  __| |  _  /
     | | \ \ ____) |___) |_| |_  | |____ / ____ \| |         | |   _| |_| |  | | |____| | \ \
     |_|  \_\_____/_____/|_____| |______/_/    \_\_|         |_|  |_____|_|  |_|______|_|  \_\
# Disclaimer
*License:* https://www.gnu.org/licenses/gpl-3.0.en.html
*Author:* DARYL fpv (Antonello Galanti) #milanofpv
*Thanks:* My MilanoFPV's m8s for testing and RCdiy.ca for timer core code
*Premise:* the script, and the hardware itself, introduce  uncertainty. The measure erros is more or less repeatable so the time lap trim is acceptable. To be considered as a nice tool to measure improvements on a circuit. Said that, this script is provided as not suitable for official race.
# Description
OpenTX Lua telemetry script suitable for Taranis X7 and X9 family radios
Working with Taranis internal JST (2.4GHz). Long range modules not tested yet.
Compatible with OpenTX Version: 2.1.8 to 2.2.3
Works with sensor: RSSI
Displays time elapsed in minutes, seconds an miliseconds.
Timer activated by a physical or logical switch.
Laps count is triggered by a coded logical switch activated by RSSI threshold (LS20).
**WARNING:** This script will override your Logical Switches number 20!
*TODO:* code refactoring
*TODO:* consider the launch control of BF 4.0 for the THR based timer activation process
*TODO:* implement log save to SD
# Installation
**BEFORE START:** Trim your radio channels range from -100 to 100 as good practice want!
 - Place the lua (this file) within Radio' SD Card:*/SCRIPTS/TELEMETRY/*
 - Place the whole accompanying folder "LamTmr" within Radio' SD Card: */SCRIPTS/TELEMETRY/*
 - Enter to the model menu and scroll to the "Display" page. Assign "script" to one of free screen and select LapTmr.
 - From the radio main menu, long press to
   access all your screens and push page to select the LapTmr's screen.
# Configuration (must be edited)
Edit the *LapTmp.lua* and set the "*ArmSwitch*" variabel as desired. You can be assigned it to a physical switche (*sa* to *sh*) or locigal one (*ls1* to *ls32*).
Set the "*ArmSwitchOnPositio*n" if necessary. Position U (up/away from you), D (down/towards), M (middle)
**IMPORTANT:** When using logical switches use only "U" for true, "D" for false
Configure the audio features (you can avoid to edit if not sure)
# Usage
**NOTE:** The threshold value must be considered ad a circle radius and the race must be started within the RSSI's threshold area! The race from Threshold to Threshold + 3db (startTollerance costant). This value can be relaxed from code. Please, read the instruction below to understand how to use the timer at the best of its potential.
 - For best performace, orientate the antenna as follow (or specular):

            .##########################(##
                                    .*(#%%#.
                                    ##%%#%@#
                              ,*....,.,,........,
                             .. *%%%%#%%%%%%%%%..(
           *      .       .(**  #%%%%%%%%%%%%%%..((*/((.    #       , *
            \   (, &(%%,% #(#(  # .%...*...#, #..#%.# %# %%&%(..%% ,/
           *./.#.%%#&(% /%&%.%./    ......     ,.%%.(&  %%(&/%*,@/%,,(
         *.%%%# #%%**@%%(/&&.#%/   (.,.@.*.%  .#%%.%&&%%&%%%%@&%%%%%/
        /..,,*///( .....,......##(,../*,*&..,%%&(..............,.....#(%
       %%/.#&...,%./##(.....*.&&(####,./(#&&&.&&...(.(&%%%%,**...&( #/@%
       %,/..../%%&&%%%%%%......(*.  .., ../#......&&%%%%%%%&&%%/..,.#/@@
        , ../%%@&&&&&&&&&&&%%(.*.(/.,##%& //##...(&@@@@@@@@@@@@@&%*,...*
        ...*%&@@@@@@&@@@@@@@%%.*,.%%(/#(%.%&@/.(.%&@@@@@&(%/&@@@@@%,...*
        (,..%@/%%##%%%%%%%%%%&,&%%.,(/ *#%&*/&%%/%&%%%@@@  %@@&%%%%%,.(/
        ,*..%&%%%%%%&&&&%&&%,%%%.*.#&&.*,%&%.%%&&%@&%@@&&@@%%&%%...((###
        (,..%%@&&@@%#%@@@@*#%,,%%&**.&&%&,.*/%%%,,@@@&&&&&&&&&&&&@%,.(.*
       ,/,,..(&@@@&  %@@@@@&.,*%%&(*.&&&&,./#&&&,./&%@@@@@@@@@@@%%(.,,#/(
       */,**,..,&%%%%&&&%%,,,#*,**(*,&&&&,,/#**,,(,.*#%%%%,%%%%((..*%,*(#
       //,%##**,,..*/*,,,,##*@%**(#(/@&&&,/(((/*&@*(*,,,..,.....#/.&%/,(#
       */***#****&%%&%@&&&*****#/.  *.(((.  .*/#*****&%%@&&%&&/******,,(#
       */***(****/*,*/*,*,**//#(*.  .,**,   .,/##/**/,,,*/,,/#/*//*/**,(#
       *//*/,......,,,,,****////(#############(////**,,,,,,........((/%(#
       **/*(///.*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,///((#%(#
       **/*,,/*/(@@@@&&&&&&&&&&&&&&&&&&&@@@&&&&@&&&@@@@&&&&@@,,///#####((
       **/*,#@#/##*&,                                      #%,#@@,#####((
       **//.,/*/%@@@,                                      &&,.///%%###/(
       **//%@@@(%,//,                                      &(,&@@@%%%##//
       ,*//.,/*(%@@@,                                      &/@%*.*(/%%##/
        *//&&@%&@@@@,                                      @@@%*,@@@%##/.
        *//.,/*#&@@&,                                      @@@&/.*(*%##/
        *** ,***,@@@@@@@&&,,@@@@@&&,,@&/,&%&%,&%@@@(@&(@@@@@@@#(((((%%(/
         ,*//((///*,..DARYL***.,,,////////////#milano fpv((//((((((%#(/
            .....#************************//*//////////////////((#(/*

 - Place your kwad at a reasonable distance on the starting line.
 - Went to the pilot station, run the script and set the RSSI threshold just above the actual RSSI reading. **Don't move yourself from choosen position!** The timer will advise you if too close or too far.
 - Arm your kwad and, as soon as you raise the throttle up to -98%, the timer will stats. A lap will be automatically counted when the quad enter the RSSI's threshold area.
 - To stop a race, disarm your quad. To allow re-arm during a race, the timer will run in background even it disarmed. To reset the timer and start a new race, long press MENU button following by OK to confirm.

**Button usage:**
 - "MENU" navigate throught "RACE TIMER" and "STATISTICS" view
 - "LONG PRESS MENU" to reset the race timer and stats
 - "ENTER" call the threshold setup menu "EXIT" open a short user guide
 - "LONG PRESS EXIT" quit the script (still running in background)
