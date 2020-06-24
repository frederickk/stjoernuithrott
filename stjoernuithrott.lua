--                        
-- ---    ---    ----    ---    ---
--      ---      ----      ---
--                        
--                        
-- ---      ---       ---       ---
-- ---      ---       ---       ---
-- ---                          ---
--
-- Stjörnuíþrótt
--
-- 1.0.0 @frederickk
-- https://github.com/frederickk/stjoernuithrott
-- llllllll.co/t/xxx
--
-- K2    Cycle through params
-- K3    Toggle suboctave
--
-- E1    Pitch (hz)
-- E2-E4 Adjust highlighted params
--
-- Twiddle the knobs and revel in the chaos
-- ...or check out the README for more details

engine.name = "SCgazer"


local music_util = require "musicutil"
local page = 1

-- constants
local VIEWPORT = {
  width = 128,
  height = 64
}
local OFF = 2
local ON = 15
local LFO_TYPE = {
  "Tri",
  "Saw",
  "Pulse",
}


-- Add parameters to parameter page
function add_params()
  params:add_separator()
  -- freq, 62.midicps, //Pitch
  params:add_control("freq", "Pitch", controlspec.new(1, 1320, "exp", 0.5, 440, "hz"))
  params:set_action("freq", function(x) engine.freq(x) end)

  -- wave, 9, //waveform selector 0 to 89 waveform
  params:add_control("wave", "Waveform", controlspec.new(0, 89, "lin", 1, 0, ""))
  params:set_action("wave", function(x) engine.wave(x) end)

  -- detune, 1.midiratio, //detune parameter of the second oscillator
  params:add_control("detune", "Detune", controlspec.new(0, 1, "lin", 0.01, 0, ""))
  params:set_action("detune", function(x) engine.detune(x) end)

  -- sub, 1, // 1 takes detune one octave lower, 0 for using detune as it is
  params:add_control("sub", "Sub", controlspec.new(0, 1, "lin", 1, 1, ""))
  params:set_action("sub", function(x) engine.sub(x) end)

  -- mix, 0, // Mix for 2 oscillator. -1 is 1st oscillator and 1 for the 2nd oscillator only 0 is the middle
  params:add_control("mix", "Mix", controlspec.new(-1, 1, "lin", 0.01, 0, ""))
  params:set_action("mix", function(x) engine.mix(x) end)


  params:add_separator()
  -- alias, 44100, // Sample rate reduction in Hz
  params:add_control("alias", "Sample rate reduction", controlspec.new(100, 48000, "lin", 100, 44100, "hz"))
  params:set_action("alias", function(x) engine.alias(x) end)

  -- redux, 24, // Bit rate reduction between 0-24 bits
  params:add_control("redux", "Bit rate reduction", controlspec.new(0, 24, "lin", 0.01, 24, ""))
  params:set_action("redux", function(x) engine.redux(x) end)

  -- gain, -1, // Gain stage for distortion kinda effect -1 is clean, 1 is dirty
  params:add_control("gain", "Gain", controlspec.new(-1, 1, "lin", 0.01, -1, ""))
  params:set_action("gain", function(x) engine.gain(x) end)


  params:add_separator()
  -- freq1, 800, // Cutoff frequency for the 1st filter
  params:add_control("freq1", "Filter 1 cutoff", controlspec.new(1, 1320, "exp", 0.5, 800, "hz"))
  params:set_action("freq1", function(x) engine.freq1(x) end)

  -- lfo1type1, 0, // LFO of 1st filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type1", "LFO 1 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type1", function(x) engine.lfo1type1(x) end)

    -- rate1, 10, // Rate of 1st LFO in Hz
  params:add_control("rate1", "LFO 1 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate1", function(x) engine.rate1(x) end)
  
  -- depth1, 1, // Depth of 1st LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth1", "LFO 1 depth ", controlspec.new(0, 1, "lin", 0.01, 1, ""))
  params:set_action("depth1", function(x) engine.depth1(x) end)


  params:add_separator()
  -- freq2, 800, // Cutoff frequency for the 2nd filter
  params:add_control("freq2", "Filter 2 cutoff", controlspec.new(1, 1320, "exp", 0.5, 880, "hz"))
  params:set_action("freq2", function(x) engine.freq2(x) end)

  -- lfo1type2, 0, // LFO of 2nd filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type2", "LFO 2 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type2", function(x) engine.lfo1type2(x) end)

  -- rate2, 10, // Rate of 2nd LFO in Hz
  params:add_control("rate2", "LFO 2 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate2", function(x) engine.rate2(x) end)

  -- depth2, 1, // Depth of 2nd LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth2", "LFO 2 depth ", controlspec.new(0, 1, "lin", 0.01, 1, ""))
  params:set_action("depth2", function(x) engine.depth2(x) end)


  params:add_separator()
  -- lfo1type3, 0, // LFO of amplitude choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
  params:add_control("lfo1type3", "LFO 3 type", controlspec.new(0, 2, "lin", 1, 0, ""))
  params:set_action("lfo1type3", function(x) engine.lfo1type3(x) end)

  -- rate3, 10, // Rate of 3rd LFO in Hz
  params:add_control("rate3", "LFO 3 rate", controlspec.new(1, 1320, "exp", 0.5, 10, "hz"))
  params:set_action("rate3", function(x) engine.rate3(x) end)

  -- depth3, 1, // Depth of 3rd LFO in Hz, 1 means no modulation, 0 is max
  params:add_control("depth3", "LFO 3 depth ", controlspec.new(0, 1, "lin", 0.01, 1, ""))
  params:set_action("depth3", function(x) engine.depth3(x) end)


  params:add_separator()
  params:add_control("amp", "Volume", controlspec.new(0, 1, "lin", 0.01, 1, ""))
  params:set_action("amp", function(x) engine.amp(x) end)
  

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
      hz = music.note_num_to_freq(d.note)

      params:set("freq", hz)
      params:set("amp", d.vel / 127)
    end

    redraw()
  end
end


function enc(n, delta)
  if n == 1 then
    params:delta("freq", delta)
  end

  if page == 1 then
    if n == 2 then
      params:delta("amp", delta)
    elseif n == 4 then
      params:delta("wave", delta)
    end
    
  elseif page == 2 then
    if n == 2 then
      params:delta("detune", delta)
    elseif n == 3 then
      params:delta("mix", delta)
    elseif n == 4 then
      params:delta("gain", delta)
    end

  elseif page == 3 then
    if n == 2 then
      params:delta("freq1", delta)
    elseif n == 3 then
      params:delta("freq2", delta)
    end

  elseif page == 4 then
    if n == 2 then
      params:delta("lfo1type2", delta)
    elseif n == 3 then
      params:delta("lfo1type3", delta)
    elseif n == 4 then
      params:delta("lfo1type1", delta)
    end

  elseif page == 5 then
    if n == 2 then
      params:delta("rate2", delta)
    elseif n == 3 then
      params:delta("rate3", delta)
    elseif n == 4 then
      params:delta("rate1", delta)
    end

  elseif page == 6 then
    if n == 2 then
      params:delta("depth2", delta)
    elseif n == 3 then
      params:delta("depth3", delta)
    elseif n == 4 then
      params:delta("depth1", delta)
    end

  elseif page == 7 then
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
    page = page + 1
  elseif n == 3 and state == 1 then  
    if (params:get("sub") == 1) then
      params:set("sub", 0)
    else
      params:set("sub", 1)
    end
  end
  
  if page > 7 then
    page = 1
  end

  redraw()
end


function highlight(on, off, page_num)
  if page == page_num then
    screen.level(on)
  else
    screen.level(off)
  end
end


function redraw()
  screen.clear()
  
  screen.level(ON)
  screen.move(VIEWPORT.width * 0, 10)
  screen.text(params:get("freq"))
  screen.move(VIEWPORT.width * 0, 20)
  screen.text(note_octave(music_util.freq_to_note_num(params:get("freq"))))

  screen.move(VIEWPORT.width * .75, 10)
  screen.text_center(params:get("sub"))

  screen.level(OFF)
  screen.move(VIEWPORT.width * .75, VIEWPORT.height * .5)
  screen.text_center("P"..page)
  screen.line_width(1)
  screen.rect((VIEWPORT.width * .75) - 5, (VIEWPORT.height * .5) - 6, 12, 9)
  screen.stroke()


  -- page 1 
  screen.move(VIEWPORT.width * .25, 10)
  highlight(ON, OFF, 1)
  screen.text_center("W"..params:get("wave") + 1)

  screen.move(VIEWPORT.width * .5, VIEWPORT.height * .5)
  highlight(ON, OFF, 1)
  screen.text_center(params:get("amp"))

  -- page 2
  screen.move(VIEWPORT.width * .5, 10)
  highlight(ON, OFF, 2)
  screen.text_center(params:get("detune"))

  screen.move(VIEWPORT.width, 10)
  highlight(ON, OFF, 2)
  mix_str = ""
  if (params:get("mix") < 0) then
    mix_str = "L"..math.abs(params:get("mix"))
  elseif (params:get("mix") > 0) then
    mix_str = "R"..params:get("mix")
  else
    mix_str = "C"
  end
  screen.text_right(mix_str)

  screen.move(VIEWPORT.width * .75, 20)
  highlight(ON, OFF, 2)
  screen.text_center(params:get("gain"))

  -- page 3
  screen.move(VIEWPORT.width * 0, 44)
  highlight(ON, OFF, 3)
  screen.text(params:get("freq1"))
  
  screen.move(VIEWPORT.width * 0, 54)
  highlight(ON, OFF, 3)
  screen.text(params:get("freq2"))

  -- page 4
  screen.move(VIEWPORT.width * .33, 44)
  highlight(ON, OFF, 4)
  screen.text_center(LFO_TYPE[params:get("lfo1type1") + 1])

  screen.move(VIEWPORT.width * .33, 54)
  highlight(ON, OFF, 4)
  screen.text_center(LFO_TYPE[params:get("lfo1type2") + 1])

  screen.move(VIEWPORT.width * 0, 64)
  highlight(ON, OFF, 4)
  screen.text(LFO_TYPE[params:get("lfo1type3") + 1])

  -- page 5
  screen.move(VIEWPORT.width * .66, 44)
  highlight(ON, OFF, 5)
  screen.text_center(params:get("rate1"))
  screen.circle((VIEWPORT.width * .66) - 17.5, 41, 3)
  screen.fill()

  screen.move(VIEWPORT.width * .66, 54)
  highlight(ON, OFF, 5)
  screen.text_center(params:get("rate2"))
  screen.circle((VIEWPORT.width * .66) - 17.5, 51, 3)
  screen.fill()

  screen.move(VIEWPORT.width * .5, 64)
  highlight(ON, OFF, 5)
  screen.text_center(params:get("rate3"))
  screen.circle((VIEWPORT.width * .5) - 17, 61, 3)
  screen.fill()

  -- page 6
  screen.move(VIEWPORT.width, 44)
  highlight(ON, OFF, 6)
  screen.text_right(params:get("depth1"))

  screen.move(VIEWPORT.width, 54)
  highlight(ON, OFF, 6)
  screen.text_right(params:get("depth2"))

  screen.move(VIEWPORT.width, 64)
  highlight(ON, OFF, 6)
  screen.text_right(params:get("depth3"))

  -- page 7
  screen.move(VIEWPORT.width * .25, 20)
  highlight(ON, OFF, 7)
  screen.text_center(params:get("alias"))

  screen.move(VIEWPORT.width * .5, 20)
  highlight(ON, OFF, 7)
  screen.text_center(params:get("redux"))


  screen.update()
end


function cleanup()
  params:write()
end


function note_octave(num)
  octave = math.floor((num / 12) - 1)
  notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
  return notes[(num % 12) + 1] .. octave
end

