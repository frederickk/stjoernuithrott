--                        
-- ---    ---    ----    ---    ---
--      ---      ----      ---
--      ---    ---         ---
-- ---      ---       ---       ---
-- ---      ---       ---       ---
-- ---            ---           ---
--
--
-- Stjoernuithrott
--
-- 1.0.0 @frederickk
-- llllllll.co/t/33889
--
-- K2    Toggle sub-octave
--
-- E1    Cycle through params
-- E4    Pitch (hz) [Fates only]
-- E2-E3 Adjust highlight params
--
-- Twiddle the knobs and revel
-- in the chaos... or check out
-- the README for more details
--


engine.name = "SCgazer"


local music_util = require "musicutil"

-- constants
local VIEWPORT = {
  width = 128,
  height = 64
}
local FIRST_PAGE = 0
local OFF = 2
local ON = 15
local LFO_TYPE = {
  "Tri",
  "Saw",
  "Pulse",
}


-- Add parameters
function add_params()
  -- Parameter page
  params:add_number("page", "page", FIRST_PAGE - 1, 11, 1)
  params:hide("page")


  params:add_separator()
  -- Pitch
  params:add_control("freq", "Pitch", controlspec.new(1, 1320, "exp", 0.5, 440, "hz"))
  params:set_action("freq", function(x) engine.freq(x) end)

  -- Waveform
  params:add_control("wave", "Waveform", controlspec.new(0, 89, "lin", 1, 0, ""))
  params:set_action("wave", function(x) engine.wave(x) end)

  -- Detune parameter of the second oscillator
  params:add_control("detune", "Detune", controlspec.new(0, 1, "lin", 0.01, 1, "%"))
  params:set_action("detune", function(x) engine.detune(x) end)

  -- Detunes second oscillator one octave lower, 0 for using detune as it is
  params:add_control("sub", "Sub", controlspec.new(0, 1, "lin", 1, 1, ""))
  params:set_action("sub", function(x) engine.sub(x) end)

  -- Mix for 2 oscillator. -1 is 1st oscillator and 1 for the 2nd oscillator only 0 is the middle
  params:add_control("mix", "Mix", controlspec.new(-1, 1, "lin", 0.01, 0, ""))
  params:set_action("mix", function(x) engine.mix(x) end)


  params:add_separator()
  -- Sample rate reduction in Hz
  params:add_control("alias", "Sample rate reduction", controlspec.new(100, 48000, "lin", 100, 44100, "hz"))
  params:set_action("alias", function(x) engine.alias(x) end)

  -- Bit rate reduction between 0-24 bits
  params:add_control("redux", "Bit rate reduction", controlspec.new(0, 24, "lin", 0.01, 24, ""))
  params:set_action("redux", function(x) engine.redux(x) end)

  -- Gain stage for distortion kinda effect -1 is clean, 1 is dirty
  params:add_control("gain", "Gain", controlspec.new(-1, 1, "lin", 0.01, -1, ""))
  params:set_action("gain", function(x) engine.gain(x) end)


  params:add_separator()
  -- Cutoff frequency for the 1st filter
  params:add_control("freq1", "Filter 1 cutoff", controlspec.new(1, 1320, "exp", 0.5, 800, "hz"))
  params:set_action("freq1", function(x) engine.freq1(x) end)

  -- LFO of 1st filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type1", "LFO 1 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type1", function(x) engine.lfo1type1(x) end)

  -- Rate of 1st LFO in Hz
  params:add_control("rate1", "LFO 1 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate1", function(x) engine.rate1(x) end)
  
  -- Depth of 1st LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth1", "LFO 1 depth ", controlspec.new(0, 1, "lin", 0.01, 0.5, ""))
  params:set_action("depth1", function(x) engine.depth1(x) end)


  params:add_separator()
  -- Cutoff frequency for the 2nd filter
  params:add_control("freq2", "Filter 2 cutoff", controlspec.new(1, 1320, "exp", 0.5, 880, "hz"))
  params:set_action("freq2", function(x) engine.freq2(x) end)

  -- LFO of 2nd filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type2", "LFO 2 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type2", function(x) engine.lfo1type2(x) end)

  -- Rate of 2nd LFO in Hz
  params:add_control("rate2", "LFO 2 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate2", function(x) engine.rate2(x) end)

  -- Depth of 2nd LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth2", "LFO 2 depth ", controlspec.new(0, 1, "lin", 0.01, 0.5, ""))
  params:set_action("depth2", function(x) engine.depth2(x) end)


  params:add_separator()
  -- LFO of amplitude choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type3", "LFO 3 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type3", function(x) engine.lfo1type3(x) end)

  -- Rate of 3rd LFO in Hz
  params:add_control("rate3", "LFO 3 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate3", function(x) engine.rate3(x) end)

  -- Depth of 3rd LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth3", "LFO 3 depth ", controlspec.new(0, 1, "lin", 0.01, 0.5, ""))
  params:set_action("depth3", function(x) engine.depth3(x) end)


  params:add_separator()
  -- Volume
  params:add_control("amp", "Volume", controlspec.new(0, 100, "lin", 1, 100, "%"))
  params:set_action("amp", function(x) engine.amp(x / 100) end)
  
  -- Load saved params
  params:read()
end


-- Initialize
function init()
  print("Stargazer")

  add_params()
  init_midi()
  screen.aa(0)
  redraw()
end


-- Initialize Midi
function init_midi()
  m = midi.connect()

  m.event = function(data)
    local d = midi.to_msg(data)
    
    if d.type == "note_on" then
      hz = music_util.note_num_to_freq(d.note)

      params:set("freq", hz)
      params:set("amp", (d.vel / 127) * 100)
    end

    redraw()
  end
end


function enc(n, delta)
  if n == 1 then
    params:delta("page", delta)

    if (params:get("page") > 10) then
      params:set("page", FIRST_PAGE)
    elseif (params:get("page") < FIRST_PAGE) then
      params:set("page", 10)
    end
  end

  if (#norns.encoders.accel == 4) then  
    -- Fates only; persistent pitch adjustment
    if n == 4 then
      params:delta("freq", delta)
    end
  else 
    -- Norns; pitch only on page 0
    if params:get("page") == 0 then
      if n == 2 then
        params:delta("freq", delta)
      end
    end
  end

  if params:get("page") == 0 then
    if n == 3 then
      params:delta("detune", delta)
    end

  elseif params:get("page") == 1 then
    if n == 2 then
      params:delta("amp", delta)
    elseif n == 3 then
      params:delta("gain", delta)
    end

  elseif params:get("page") == 2 then
    if n == 2 then
      params:delta("wave", delta)
    elseif n == 3 then
      params:delta("mix", delta)
    end

  elseif params:get("page") == 3 then
    if n == 2 then
      params:delta("freq1", delta)
    elseif n == 3 then
      params:delta("freq2", delta)
    end

  elseif params:get("page") == 4 then
    if n == 2 then
      params:delta("lfo1type1", delta)
    elseif n == 3 then
      params:delta("rate1", delta)
    end

  elseif params:get("page") == 5 then
    if n == 2 then
      params:delta("lfo1type1", delta)
    elseif n == 3 then
      params:delta("depth1", delta)
    end
  
  elseif params:get("page") == 6 then
    if n == 2 then
      params:delta("lfo1type2", delta)
    elseif n == 3 then
      params:delta("rate2", delta)
    end

  elseif params:get("page") == 7 then
    if n == 2 then
      params:delta("lfo1type2", delta)
    elseif n == 3 then
      params:delta("depth2", delta)
    end

  elseif params:get("page") == 8 then
    if n == 2 then
      params:delta("lfo1type3", delta)
    elseif n == 3 then
      params:delta("rate3", delta)
    end

  elseif params:get("page") == 9 then
    if n == 2 then
      params:delta("lfo1type3", delta)
    elseif n == 3 then
      params:delta("depth3", delta)
    end

  elseif params:get("page") == 10 then
    if n == 2 then
      params:delta("alias", delta)
    elseif n == 3 then
      params:delta("redux", delta)
    end
  end

  redraw()
end


function key(n, state)
  if n == 2 and state == 1 then
    if (params:get("sub") == 1) then
      params:set("sub", 0)
    else
      params:set("sub", 1)
    end
  end

  redraw()
end


function redraw()
  screen.clear()
  
  -- Page marker
  screen.level(ON)
  screen.move(VIEWPORT.width * .85, VIEWPORT.height * .5)
  screen.text_center("P" .. params:get("page"))
  screen.line_width(1)
  screen.rect((VIEWPORT.width * .85) - 7, (VIEWPORT.height * .5) - 6, 15, 8)
  screen.stroke()

  -- page 0
  page = 0
  if (#norns.encoders.accel == 4) then  
    screen.level(ON)
  else
    highlight(ON, OFF, page)
  end
  screen.move(VIEWPORT.width * 0, 10)
  screen.text(params:get("freq"))
  screen.move(VIEWPORT.width * 0, 20)
  screen.text(note_octave(music_util.freq_to_note_num(params:get("freq"))))

  led(VIEWPORT.width * .75, 7, params:get("sub"))

  screen.move(VIEWPORT.width * .5, 10)
  highlight(ON, OFF, page)
  screen.text_center(params:get("freq") * params:get("detune"))
  detune_note = note_octave(music_util.freq_to_note_num(params:get("freq") * params:get("detune")))
  -- screen.text_center(math.floor(params:get("detune") * 100) .. "%")
  screen.move(VIEWPORT.width * .5, 20)
  screen.text_center(detune_note)

  -- page 1 
  page = 1
  screen.move(VIEWPORT.width * .75, 20)
  highlight(ON, OFF, page)
  screen.text_center(params:get("amp") .. "%")

  screen.move(VIEWPORT.width * .25, 20)
  highlight(ON, OFF, page)
  screen.text_center(params:get("gain"))

  -- page 2
  page = 2
  screen.move(VIEWPORT.width * .25, 10)
  highlight(ON, OFF, page)
  screen.text_center("W" .. params:get("wave") + 1)

  screen.move(VIEWPORT.width, 10)
  highlight(ON, OFF, page)
  mix_str = ""
  if (params:get("mix") < 0) then
    mix_str = "L" .. math.abs(params:get("mix"))
  elseif (params:get("mix") > 0) then
    mix_str = "R" .. params:get("mix")
  else
    mix_str = "C"
  end
  screen.text_right(mix_str)

  -- page 3
  page = 3
  screen.move(VIEWPORT.width * 0, 44)
  highlight(ON, OFF, page)
  screen.text(params:get("freq1"))
  
  screen.move(VIEWPORT.width * 0, 54)
  highlight(ON, OFF, page)
  screen.text(params:get("freq2"))

  -- page 4
  page = 4
  screen.move(VIEWPORT.width * .33, 44)
  highlight(ON, OFF, page, page + 1)
  screen.text_center(LFO_TYPE[params:get("lfo1type1") + 1])

  screen.move(VIEWPORT.width * .66, 44)
  highlight(ON, OFF, page)
  screen.text_center(params:get("rate1"))
  led((VIEWPORT.width * .66) - 17.5, 41, 1)

  -- page 5
  page = 5
  screen.move(VIEWPORT.width, 44)
  highlight(ON, OFF, page)
  screen.text_right(params:get("depth1"))

  -- page 6
  page = 6
  screen.move(VIEWPORT.width * .33, 54)
  highlight(ON, OFF, page, page + 1)
  screen.text_center(LFO_TYPE[params:get("lfo1type2") + 1])

  screen.move(VIEWPORT.width * .66, 54)
  highlight(ON, OFF, page)
  screen.text_center(params:get("rate2"))
  led((VIEWPORT.width * .66) - 17.5, 51, 1)

  -- page 7
  page = 7
  screen.move(VIEWPORT.width, 54)
  highlight(ON, OFF, page)
  screen.text_right(params:get("depth2"))

  -- page 8
  page = 8
  screen.move(VIEWPORT.width * 0, 64)
  highlight(ON, OFF, page, page + 1)
  screen.text(LFO_TYPE[params:get("lfo1type3") + 1])

  screen.move(VIEWPORT.width * .5, 64)
  highlight(ON, OFF, page)
  screen.text_center(params:get("rate3"))
  led((VIEWPORT.width * .5) - 17, 61, 1)

  -- page 9
  page = 9
  screen.move(VIEWPORT.width, 64)
  highlight(ON, OFF, page)
  screen.text_right(params:get("depth3"))

  -- page 10
  page = 10
  screen.move(VIEWPORT.width * .25, VIEWPORT.height * .5)
  highlight(ON, OFF, page)
  screen.text_center(params:get("alias"))

  screen.move(VIEWPORT.width * .5, VIEWPORT.height * .5)
  highlight(ON, OFF, page)
  screen.text_center(params:get("redux"))

  screen.update()
end


function cleanup()
  params:write()
end


-- Displays note name and octave based on Midi note number
-- num: Midi note number
function note_octave(num)
  octave = math.floor((num / 12) - 1)
  notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
  return notes[(num % 12) + 1] .. octave
end


-- Toggles the brightness of an element based on page
-- on: brightnless level for "on" state
-- off: brightnless level for "off" state
-- page_num: page number to toggle "on" state
function highlight(on, off, page_num, page_num_alt)
  if params:get("page") == page_num or params:get("page") == page_num_alt then
    screen.level(on)
  else
    screen.level(off)
  end
end


-- Creates activity element to signify status of parameter
-- x: X-coordinate of element
-- y: Y-coordinate of element
-- state: 1 is active, 0 is inactive
function led(x, y, state)
  screen.move(x + 3, y) -- hacky way to fix visual glitch
  screen.circle(x, y, 3)

  if state == 1 then
    screen.fill()
  else
    screen.stroke()
  end
end
