--------------------- Configuration (read README.md before!) ------------------------------
-- Set the arm switch assignment as desired. You can be assigned to physical switches (sa to sh) or locigal ones (ls1 to ls32).
local ArmSwitch = "sa"
-- Position U (up/away from you), D (down/towards), M (middle)
-- IMPORTANT: When using logical switches use "U" for true, "D" for false
local ArmSwitchOnPosition = "U"

-- Audio features (you can avoid to edit if not sure)
local SpeakLapTime = false
local SpeakLapNumber = true -- (with radio voice)
local SpeakLapTimeHours = 0 -- 1 hours, minutes, seconds else minutes, seconds
local BeepOnLap = true
local BeepFrequency = 600 -- Hz
local BeemLengthMiliseconds = 200
local AnnounceBestLap = true

------------------------------------------------------------------------------------------
--------------------- AVOID EDITING BELOW HERE -------------------------------------------
------------------------------------------------------------------------------------------
local version = "v.92"-- Web: https://www.facebook.com/groups/MilanoFPV/
local LapSwitch = "ls20" -- trig the lap count by a logical switch created by this script
local LapSwitchRecordPosition = "U"
-- File Paths
local SoundFilesPath = "/SCRIPTS/TELEMETRY/LapTmr/sound/"
local ImageFilesPath = "/SCRIPTS/TELEMETRY/LapTmr/gfx/"
-- Variables local to this script (must use the word "local" before the variable)
local nowTime = 0
local startTime = 0
-- Signal strenght
local RssiChannel = getFieldInfo("RSSI")
local rssi, alarm_low, alarm_crit = getRSSI()
local threshold = 95 --starting threshold
-- Display navigation
local SPLASH_SCREEN = 0
local RACE_SCREEN = 1
local CONFIGURATION_SCREEN = 2
local POST_RACE_SCREEN = 3
local RESET_SCREEN = 4
local HELP_SCREEN = 5
local currentScreen = SPLASH_SCREEN
local previousScreen = RACE_SCREEN
-- Time Tracking
local StartTimeMiliseconds = -1
local ElapsedTimeMiliseconds = 0
local PreviousElapsedTimeMiliseconds = 0
local LapTime = 0
local LapTimeList = {ElapsedTimeMiliseconds}
local LapTimeRecorded = false
local SumTime = 0
local BestLap = 4095 -- dummy value
local raceStarted = false
local readyToStart = false
local startTollerance = 3 --RSSI tollerance respect the choosen starting point
-- Display
local TextHeader = "Time"
local TextSize = 0
local TextHeight = 12
local Debuging = false

--------------------- Functions ----------------------------------------------------------
local function showSplash( msecs )
  -- for compatibility to the X9 series, I load a pixmap instead of a BMP
  lcd.clear()
  if startTime == 0 then
    startTime = getTime() -- Useful for the splash screen
  end
  if LCD_W >= 212 then
    lcd.drawPixmap(0, 0, ImageFilesPath.."logo_1_x9.bmp")
    lcd.drawPixmap (106, 0, ImageFilesPath.."logo_2_x9.bmp") --64,0
    lcd.drawText( 2, 57, version, SMLSIZE + INVERS) --x,3
  elseif LCD_W == 128 then
    lcd.drawPixmap(0, 0, ImageFilesPath.."logo_1_x7.bmp")
    lcd.drawPixmap (64, 0, ImageFilesPath.."logo_2_x7.bmp") --64,0
    lcd.drawText( 2, 57, version, SMLSIZE + INVERS) --x,3
  end
  nowTime = getTime()
  if nowTime - startTime >= msecs then
    currentScreen = CONFIGURATION_SCREEN
    return
  end
end

local function getTimeMiliSeconds()
  -- Returns the number of miliseconds elapsed since the Tx was turned on
  -- Increments in 10 milisecond intervals
  -- Return the time since the radio was started in multiple of 10ms
  -- Number of 10ms ticks since the radio was started Example: run time: 12.54 seconds, return value: 1254
  local now = getTime() * 10
  return now
end

local function getMinutesSecondsHundrethsAsString(miliseconds)
  -- Returns M:SS.hh as a string
  -- miliseconds = miliseconds or 0
  local seconds = miliseconds/1000
  local minutes = math.floor(seconds/60) -- seconds/60 gives minutes
  seconds = seconds % 60 -- seconds % 60 gives seconds
  return  (string.format("%d:%05.2f", minutes, seconds))
end

local function getSwitchPosition( switchID )
  -- Returns switch position as one of U,D,M
  -- Passed a switch identifier sa to sf, ls1 to ls32
  local switchValue = getValue(switchID)
  if Debuging == true then
    print(switchValue)
  end
  -- typical Tx switch middle value is
  if switchValue < -100 then
    return "D"
  elseif switchValue < 100 then
    return "M"
  else
    return "U"
  end
end

local function configuration_func(event)
  lcd.clear()
  lcd.drawRectangle(3, 3, LCD_W-6, LCD_H-6, SOLID)
  lcd.drawRectangle(4, 4, LCD_W-6, LCD_H-6, GREY_DEFAULT)
  --rssi, alarm_low, alarm_crit = getRSSI()
  if LCD_W >= 212 then
    lcd.drawText( 6, 6, "Set the RSSI threshold to trig the lap timer.", SMLSIZE + INVERS)
    lcd.drawText( 33, 46, " ENTER TO SET ", SMLSIZE + INVERS + BLINK)
    lcd.drawText( 8, 19, "RSSI Threshold:", TextSize)
    lcd.drawText( 128, 18, string.format("%03d",threshold), XXLSIZE)
    lcd.drawText( 197, 50, "db", SMLSIZE)
    lcd.drawGauge(13, 33, 100, 6, rssi, 100)
    lcd.drawLine(13+threshold, 32, 13+threshold, 39, SOLID, FORCE)
  elseif LCD_W == 128 then
    lcd.drawText( 6, 6, "Set the RSSI threshold", TextSize + INVERS)
    lcd.drawText( 6, 15, "to trig the lap timer.   ", TextSize + INVERS)
    lcd.drawText( 30, 49, " ENTER TO SET ", TextSize + INVERS + BLINK)
    lcd.drawText( 8, 29, "RSSI Threshold:", TextSize)
    lcd.drawText( 92, 26, string.format("%03d",threshold), MIDSIZE)
    lcd.drawText( 113, 31, "db", SMLSIZE)
    lcd.drawGauge(13, 39, 100, 6, rssi, 100)
    lcd.drawLine(13+threshold, 38, 13+threshold, 45, SOLID, FORCE)
  end
  if rssi ~= 0 then -- if no signal, you can't move (and save the threshold, as well)
    if event == EVT_ENTER_BREAK or event==EVT_ROT_BREAK then
      model.setLogicalSwitch(19, {func=3,v1=RssiChannel["id"],v2=threshold, ["delay"]=5}) -- LS20 Trig the lap counter: a>x RSSI xxdb DELAY 0.5s
      currentScreen = RACE_SCREEN
      return
    elseif (event == EVT_ROT_LEFT or event == EVT_MINUS_REPT or event == EVT_MINUS_FIRST or event == EVT_MINUS_LONG) and threshold > 0 then
      threshold = threshold - 1
      return
    elseif (event == EVT_ROT_RIGHT or event == EVT_PLUS_REPT or event == EVT_PLUS_FIRST or event == EVT_PLUS_LONG) and threshold < 100 then
      threshold = threshold + 1
      return
    end
  else -- no RSSI signal
    popupWarning("Looking for Kwad...", event)
    -- To hang the navigation, exit event is not considered
  end
end

local function resetTimer(event)
  popupConfirmation("Reset timer?", EVT_ENTER_BREAK)
  if event == EVT_ENTER_BREAK then
    StartTimeMiliseconds = -1
    ElapsedTimeMiliseconds = 0
    PreviousElapsedTimeMiliseconds = 0
    LapTime = 0
    LapTimeList = {0}
    SumTime = 0
    BestLap = 4095 -- dummy value
    raceStarted = false -- throttle memory
    readyToStart = false
    playTone(440,110,0)
    playTone(660,110,0)
    playTone(880,110,0)
    currentScreen = RACE_SCREEN
    return
  elseif event == EVT_EXIT_BREAK then
    currentScreen = previousScreen
    return
  end
end

local function race_func(event)
  -- LCD / Display code
  lcd.clear()
  if LCD_W >= 212 then
    lcd.drawPixmap(0, 0, ImageFilesPath.."bg_1_x9.bmp")
    lcd.drawPixmap (106, 0, ImageFilesPath.."bg_2_x9.bmp") --64,0
  elseif LCD_W == 128 then
    lcd.drawPixmap(0, 0, ImageFilesPath.."bg_1_x7.bmp")
    lcd.drawPixmap (64, 0, ImageFilesPath.."bg_2_x7.bmp") --64,0
  end
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  if LCD_W >= 212 then
    lcd.drawText( 5, 1, TextHeader, TextSize + INVERS) --5,3
  elseif LCD_W == 128 then
    lcd.drawText( 3, 4, TextHeader, TextSize + INVERS) --5,3
  end

  local x = lcd.getLastPos() + 4
  if LCD_W >= 212 then
    lcd.drawText( x, 1, getMinutesSecondsHundrethsAsString(ElapsedTimeMiliseconds), MIDSIZE + INVERS) --x,3
  elseif LCD_W == 128 then
    lcd.drawText( x, 1, getMinutesSecondsHundrethsAsString(ElapsedTimeMiliseconds), MIDSIZE + INVERS) --x,3
  end

  x = lcd.getLastPos() + 4
  if LCD_W >= 212 then
    lcd.drawText( x+73, 1, "Lap", TextSize + INVERS) --x,3
  elseif LCD_W == 128 then
    lcd.drawText( x+16, 4, "Lap", TextSize + INVERS) --x,3
  end

  x = lcd.getLastPos() + 4
  lcd.drawText( x, 1, string.format("%02d",#LapTimeList-1),  MIDSIZE)
  local rowHeight = math.floor(TextHeight + 2) --12
  local rows = math.floor(LCD_H/rowHeight)
  local rowsMod=rows*rowHeight
  x = 0
  local y = rowHeight
  local c = 1

 --rssi, alarm_low, alarm_crit = getRSSI()
  if LCD_W >= 212 then
    if rssi > 0 then
      lcd.drawText( 45, 57, "RSSI", SMLSIZE + INVERS) --x,3
      lcd.drawGauge(65, 57, 100, 5, rssi, 100)
      lcd.drawLine(65+threshold , 56, 65+threshold , 62, SOLID, ERASE) -- range per linea 28:128
    else
      lcd.drawText( 58, 57, "No signal from radio!", SMLSIZE + INVERS + BLINK) --x,3
    end
  elseif LCD_W == 128 then
    if rssi > 0 then
      lcd.drawText( 5, 56, "RSSI", SMLSIZE + INVERS) --x,3
      lcd.drawGauge(26, 56, 100, 6, rssi, 100) -- range per linea 29:122
      lcd.drawLine(26+threshold , 55, 26+threshold, 62, SOLID, ERASE) --126:26
    else
      lcd.drawText( 18, 56, "No signal from radio!", SMLSIZE + INVERS + BLINK) --x,3
    end
  end

  -- i = 2 first entry is always 0:00.00 so skippind it
  for i = #LapTimeList, 2, -1 do
    if y %  (rowsMod or 60) == 0 then
      c = c + 1 -- next column
      x = lcd.getLastPos()
      y = rowHeight
    end
    if (c > 1) and x > LCD_W - x/(c-1) then
    else
      if LCD_W >= 212 then
        lcd.drawText( x+9, y+1, LapTimeList[i],TextSize)
      elseif LCD_W == 128 then
        lcd.drawText( x+10, y+3, LapTimeList[i],TextSize)
      end
    end
    y = y + rowHeight
  end

if raceStarted == false and getSwitchPosition(ArmSwitch) == ArmSwitchOnPosition then --messages if armed but not ready
      	if rssi>threshold and rssi<threshold+startTollerance and getValue('thr') <= -98 then
    		readyToStart = false
      		popupWarning("--READY TO START--",event)
    		--return 	
      	elseif rssi<=threshold then
    		readyToStart = false
    		popupWarning("Kwad too far!",event)
    		--return    		
      	elseif rssi>=threshold+startTollerance then
    		readyToStart = false
    		popupWarning("Kwad too close!",event)
    		--return
    	elseif rssi>threshold and getValue('thr') > -98 then
    		readyToStart = true
    		LapTimeRecorded = true -- avoid to record the first dummy lap 0:00.00
    		return
    	end
end

  -- event management
  if event == EVT_MENU_BREAK then
    currentScreen = POST_RACE_SCREEN
    return
  elseif event == EVT_MENU_LONG then
    previousScreen = currentScreen
    currentScreen = RESET_SCREEN
    return
  elseif event == EVT_ROT_BREAK or event == EVT_ENTER_BREAK then
    currentScreen = CONFIGURATION_SCREEN
    return
  elseif event == EVT_EXIT_BREAK then
    previousScreen = currentScreen
    currentScreen = HELP_SCREEN
    return
  end
  return 0
end

local function race_summary(event)
  lcd.clear()
  if (#LapTimeList-1) ~= 0 then -- there are stats to show
    if LCD_W >= 212 then
      lcd.drawPixmap(0, 0, ImageFilesPath.."summary_1_x9.bmp")
      lcd.drawPixmap (106, 0, ImageFilesPath.."summary_2_x9.bmp") --64,0
      lcd.drawText( 16, 14, "Total laps:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 14, string.format("%02d",#LapTimeList-1), SMLSIZE)
      lcd.drawText( 16, 24, "Best lap:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 24, getMinutesSecondsHundrethsAsString(BestLap), SMLSIZE + BLINK)
      lcd.drawText( 16, 34, "Mean time:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 34, getMinutesSecondsHundrethsAsString(SumTime/(#LapTimeList-1)), SMLSIZE)
      lcd.drawText( 16, 44, "Model:", SMLSIZE)
      local modelInfos = model.getInfo()
      lcd.drawText( lcd.getLastPos()+4, 44, modelInfos["name"], SMLSIZE)
      --    lcd.drawText( 19, 38, "PAGE TO COME BACK", TextSize + INVERS + BLINK) --x,3
      lcd.drawText( 78, 57, "by DARYL fpv", SMLSIZE + INVERS)
    elseif LCD_W == 128 then
      lcd.drawPixmap(0, 0, ImageFilesPath.."summary_1_x7.bmp")
      lcd.drawPixmap (64, 0, ImageFilesPath.."summary_2_x7.bmp") --64,0
      lcd.drawText( 14, 12, "Total laps:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 12, string.format("%02d",#LapTimeList-1), SMLSIZE)
      lcd.drawText( 14, 23, "Best lap:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 23, getMinutesSecondsHundrethsAsString(BestLap), SMLSIZE + BLINK)
      lcd.drawText( 14, 34, "Mean time:", SMLSIZE)
      lcd.drawText( lcd.getLastPos()+4, 34, getMinutesSecondsHundrethsAsString(SumTime/(#LapTimeList-1)), SMLSIZE)
      lcd.drawText( 14, 45, "Model:", SMLSIZE)
      local modelInfos = model.getInfo()
      lcd.drawText( lcd.getLastPos()+4, 45, modelInfos["name"], SMLSIZE)
      lcd.drawText( 40, 57, "by DARYL fpv", SMLSIZE + INVERS) --65 48
    end
    if event == EVT_EXIT_BREAK then
      previousScreen = currentScreen
      currentScreen = HELP_SCREEN
      return
    end
    if event == EVT_MENU_BREAK then
      currentScreen = RACE_SCREEN
      return
    end
  else -- if there aren't stats to show
    if LCD_W >= 212 then
      lcd.drawPixmap(0, 0, ImageFilesPath.."summary_1_x9.bmp")
      lcd.drawPixmap (106, 0, ImageFilesPath.."summary_2_x9.bmp") --64,0

    elseif LCD_W == 128 then
      lcd.drawPixmap(0, 0, ImageFilesPath.."summary_1_x7.bmp")
      lcd.drawPixmap (64, 0, ImageFilesPath.."summary_2_x7.bmp") --64,0
    end
    popupWarning("No stats yet!", event)
    -- event managed alone to change the navigation behaviour if the popup is shown
    if event == EVT_EXIT_BREAK then
      previousScreen = currentScreen
      currentScreen = RACE_SCREEN
      return
    end
  end
  -- EVT_EXIT event splitted on conditional if
  if event == EVT_MENU_LONG then
    previousScreen = currentScreen
    currentScreen = RESET_SCREEN
    return
  elseif event == EVT_ROT_BREAK or event == EVT_ENTER_BREAK then
    currentScreen = CONFIGURATION_SCREEN
    return
  end
end

local function help_func(event)
  lcd.clear()
  lcd.drawRectangle(3, 3, LCD_W-6, LCD_H-6, SOLID)
  lcd.drawRectangle(4, 4, LCD_W-6, LCD_H-6, GREY_DEFAULT)

  if LCD_W >= 212 then
    lcd.drawText( 8, 6, "Timer will start if armed and Thr>-99.", SMLSIZE)
    lcd.drawText( 8, 13, "Laps will be triggered when RSSI overcomes", SMLSIZE)
    lcd.drawText( 8, 20, "the threshold value and persist for 0.5s.", SMLSIZE)
    lcd.drawLine(32,29,180,29, SOLID, FORCE)
    lcd.drawText( 24, 34, "          MENU           " , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 33, "screen navigation" , SMLSIZE)
    lcd.drawText( 24, 43, "  LONG PRESS MENU  " , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 42, "reset" , SMLSIZE)
    lcd.drawText( 24, 52, "          ENTER          " , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 51, "set RSSI threshold" , SMLSIZE)
  elseif LCD_W == 128 then
    lcd.drawText( 8, 7, "Timer will start if armed", SMLSIZE)
    lcd.drawText( 8, 14, "and Thr>-99. Laps will be", SMLSIZE)
    lcd.drawText( 8, 21, "trigged by the RSSI value.", SMLSIZE)
    lcd.drawLine(20,30,104,30, SOLID, FORCE)
    lcd.drawText( 10, 34, "MENU" , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 33, "screen navigation" , SMLSIZE)
    lcd.drawText( 10, 43, "LONG PRESS MENU" , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 42, "reset" , SMLSIZE)
    lcd.drawText( 10, 52, "ENTER" , SMLSIZE + INVERS)
    lcd.drawText( lcd.getLastPos()+2, 51, "set RSSI threshold" , SMLSIZE)
  end
  if (event == EVT_EXIT_BREAK) then
    currentScreen = previousScreen
    return
  end
end

local function init_func()
  lcd.clear()
  -- Called once when model is loaded or telemetry reset.
  StartTimeMiliseconds = -1
  ElapsedTimeMiliseconds = 0
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  if LCD_W > 128 then
    TextSize = MIDSIZE
  else
    TextSize = 0
  end
end

local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx
  -- print(#LapTimeList)
  -- Start recording time
  if currentScreen ~= CONFIGURATION_SCREEN and currentScreen ~= SPLASH_SCREEN then -- doesn't start the timer if boot or config screen
    if  getSwitchPosition(ArmSwitch) == ArmSwitchOnPosition and raceStarted == true then --spegnere timer switch quando disarmo senza resettare il timer. cambiare il logical switch di conseguenza
      -- Start  reference time
      if StartTimeMiliseconds == -1 then
        StartTimeMiliseconds = getTimeMiliSeconds()
      end
      -- Time difference
      ElapsedTimeMiliseconds = getTimeMiliSeconds() - StartTimeMiliseconds
      -- TimerSwitch and LapSwitch On so record the lap time
      if getSwitchPosition(LapSwitch) == LapSwitchRecordPosition then
        if LapTimeRecorded == false then
          LapTime = ElapsedTimeMiliseconds - PreviousElapsedTimeMiliseconds
          SumTime = SumTime + LapTime
          PreviousElapsedTimeMiliseconds = ElapsedTimeMiliseconds
          LapTimeList[#LapTimeList+1] = getMinutesSecondsHundrethsAsString(LapTime)
          LapTimeRecorded = true
          playHaptic(300, 0)
          playTone(BeepFrequency,BeemLengthMiliseconds,0)
          if (#LapTimeList-1) <= 16 and SpeakLapNumber then
            local filePathName = SoundFilesPath..tostring(#LapTimeList-1)..".wav"
            playFile(filePathName)
          end
          if LapTime < BestLap then
            BestLap = LapTime
            if AnnounceBestLap and (#LapTimeList-1) > 1 and (#LapTimeList-1) <= 16 then -- non conta il primo giro perchè sarebbe considerato best time
              playFile(SoundFilesPath.."better.wav")
            end
          end

          if SpeakLapTime then
            local LapTimeInt = math.floor((LapTime/1000)+0.5)
            playDuration(LapTimeInt, SpeakLapTimeHours)
          end
        end
      else
        LapTimeRecorded = false
      end
    elseif raceStarted == false and getSwitchPosition(ArmSwitch) == ArmSwitchOnPosition and readyToStart == true then -- if race not started yet but ready to go
      	raceStarted = true
      	return
    end
  end
end

local function run_func(event)
  -- Called periodically when screen is visible
  bg_func() -- a good way to reduce repitition

  rssi, alarm_low, alarm_crit = getRSSI()

  if currentScreen == SPLASH_SCREEN then
    showSplash(250)
  elseif currentScreen == CONFIGURATION_SCREEN then
    configuration_func(event)
  elseif currentScreen == RACE_SCREEN then
    race_func(event)
  elseif currentScreen == POST_RACE_SCREEN then
    race_summary(event)
  elseif currentScreen == RESET_SCREEN then
    resetTimer(event)
  elseif currentScreen == HELP_SCREEN then
    help_func(event)
  end
end

--------------------- Routines assignment ------------------------------------------------
return { run=run_func, background=bg_func, init=init_func  }
