      _____   _____ _____ _____   _               _____    _______ _____ __  __ ______ _____
     |  __ \ / ____/ ____|_   _| | |        /\   |  __ \  |__   __|_   _|  \/  |  ____|  __ \
     | |__) | (___| (___   | |   | |       /  \  | |__) |    | |    | | | \  / | |__  | |__) |
     |  _  / \___ \\___ \  | |   | |      / /\ \ |  ___/     | |    | | | |\/| |  __| |  _  /
     | | \ \ ____) |___) |_| |_  | |____ / ____ \| |         | |   _| |_| |  | | |____| | \ \
     |_|  \_\_____/_____/|_____| |______/_/    \_\_|         |_|  |_____|_|  |_|______|_|  \_\
# Disclaimer
 - *License:* https://www.gnu.org/licenses/gpl-3.0.en.html
 - *Author:* **DARYL fpv** (Antonello Galanti) **#milanofpv**
 - *Thanks:* My MilanoFPV's m8s for testing and RCdiy.ca for timer core code
 - *Premise:* the script, and the hardware itself, introduce  uncertainty. The measure erros is more or less repeatable so the time lap trim is acceptable. To be considered as a nice tool to measure improvements on a circuit. Said that, this script is provided as not suitable for official race.
# Description
 - OpenTX Lua telemetry script suitable for Taranis X7 and X9 family radios.
 - Working with Taranis internal 2.4GHz JST module (long range modules not tested yet)
 - Compatible with OpenTX Version: 2.1.8 to 2.2.3
 - Works with sensor: RSSI
 - Displays time elapsed in minutes, seconds an miliseconds of each lap and race stats.
 - Lap count is activated by a physical or logical switch.
 - Laps count is triggered by a logical switch (LS20: created by this script) activated by RSSI threshold.
**WARNING:** This script will override your Logical Switch number 20!
*TODO:* code refactoring
*TODO:* implement widget for Horus family
*TODO:* consider the "launch control" of BF 4.0 for the THR based timer activation process
*TODO:* add "save log to SD" feauture
# Installation
**BEFORE START: Trim your radio channels range from -100 to 100 (as good practice want) otherwise the timer will not work!**
 - Place the file named "*LapTmr.lua*" within this Radio' SD Card path: */SCRIPTS/TELEMETRY/*
 - Place the whole accompanying folder "*LamTmr*" within this Radio' SD Card path: */SCRIPTS/TELEMETRY/*
 - Enter to the "*Model menu*" and navigate to "*Display*" page. Assign "*Script*" to one of free screens and select "*LapTmr*".
 - From the "*Radio main menu*", long press to access all your screens and push page to navigate to LapTmr's scipt and it will run.
**NOTE:** Do not rename any file! Name file up to 6 character will not work.
# Configuration (must be edited by pilot)
- Edit the "*LapTmp.lua*" file and set the "*ArmSwitch*" variabel as desired. You can assign it to a physical switch (*sa* to *sh*) or locigal ones (*ls1* to *ls32*).
 - Set the "*ArmSwitchOnPositio*n" variable if necessary to change the active position of the arm switch. Position U (up/away from you), D (down/towards), M (middle)
**IMPORTANT:** When using logical switches, choose only "U" for true, "D" for false
 - Configure the audio features section (you can avoid to edit if not sure)
# Usage
**NOTE:** The threshold value must be considered ad a circle radius and the race must be started **within and at the edge** of the RSSI's threshold area! Your starting position must be inside the RSSI threshold value and RSSI threshodl value + 4 (defined by startTollerance costant). This value can be relaxed from code. Please, read the instruction below to understand how to use the timer at the best of its potential.
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

 - Place your kwad at a reasonable distance on the starting line. Do not run the app yet.
 - Went to the pilot station, run the script and set the RSSI threshold just below the actual RSSI reading. **Don't move yourself from choosen position!** The timer will advise you if too close or too far.
**NOTE:** The choosen threshold value can't be saved if bigger than the actual RSSI value (strenght). This because the race must start inside the threshold area.
 - Arm your kwad and, as soon as you'll raise the throttle up to -98%, the timer will stats. A lap will be automatically counted when the quad will pass through the RSSI's threshold area.
 - To stop a race, disarm your quad. To allow re-arming during a race, the timer will run in background even it the kwad is disarmed.
 - To reset the timer and start a new race, long press MENU button following by OK to confirm.

**Button usage:**
 - "MENU" navigate throught "RACE TIMER" and "STATISTICS" view
 - "LONG PRESS MENU" to reset the race timer and stats
 - "ENTER" call the threshold setup menu "EXIT" open a short user guide
 - "LONG PRESS EXIT" quit the script (still running in background)
