// SCgazer versiøn 1.0.
//
// Møffenzeef Mødular Stargazer Drone Synth Emulation
//
// Description:
//
// STARGAZER is øne beast øf a drøne machine: dual wavetable øscillatør
// with ninety arbitrary waveførms,
// twø resønant løwpass filters, three wavetable LFØ's,
// sample rate reductiøn, bit rate reductiøn,
// amplitude mødulatiøn, and CMØS distørtiøn.
// STARGAZER can handle the abuse it will inevitably take at gigs
// and is røad ready før whatever horrible treatment lies ahead.
// Stare intø the sky møuth agape while shredding
// parallel dimensiøns with this hypnøtic vømitrøn.
//
// Website: https://www.moffenzeefmodular.com/stargazer
//
// This is an emulatiøn from what the website is describing.
// I bet the hardware versiøn is much weirder and sø much more interesting.
// If you like it gø buy it.
//
// This is definetly nøt a spønsøred emulatiøn.
//
// 25/04/2020
// Bangkøk, Thailand
// K.E.
//
// Ported to Norns
// Norns version 1.0
// ken frederick
// ken.frederick@gmx.de
// https://github.com/frederickk/stargazer


Engine_SCgazer : CroneEngine {
  // Define a getter for the synth variable
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Randomly create waveforms
    ~wt = Array.fill(100, {
      var numSegs = rrand(100, 20);
      Env(
        (({rrand(0.0, 1.0)}!(numSegs-1))*[1, -1]).scramble,
        {rrand(1, 20)}!numSegs,
        'sine'
        // {rrand(-20,20)}!numSegs
      ).asSignal(1024).asWavetable;
    });

    Buffer.freeAll;
    ~vbuf = Buffer.allocConsecutive(90, context.server, 2048);
    ~vbuf.do({
      arg buf, i;
      buf.loadCollection(~wt[i]);
    });

    // Stargazer variables
    synth = {
      arg amp = 1,
        out = 0,
        pan = 0.0,
        freq = 440,
        gain = (-1.0),
        wave = 0,
        sub = 0,
        detune = 1,
        mix = (-1.0),
        freq1 = 880,
        freq2 = 880,
        res1 = 0.0,
        res2 = 0.0,
        alias = 44100,
        redux = 24,
        rate1 = 10,
        rate2 = 10,
        rate3 = 10,
        depth1 = 1,
        depth2 = 1,
        depth3 = 1,
        lfo1type1 = 0,
        lfo1type2 = 0,
        lfo1type3 = 0;
      
      var sig, detuned, pitch, lfo1, lfo2, lfo3, filter1, filter2;

      lfo1 = Select.kr(lfo1type1, [LFTri.kr(rate1), LFSaw.kr(rate1), LFPulse.kr(rate1)]);
      lfo2 = Select.kr(lfo1type2, [LFTri.kr(rate2), LFSaw.kr(rate2), LFPulse.kr(rate2)]);
      lfo3 = Select.kr(lfo1type3, [LFTri.kr(rate3), LFSaw.kr(rate3), LFPulse.kr(rate3)]);

      detuned = Select.ar(sub, [VOsc.ar(wave, freq * detune), VOsc.ar(wave, (freq * 0.5) * detune)]);

      wave = ~vbuf[0].bufnum + wave;

      sig = VOsc.ar(wave, freq);
      sig = XFade2.ar(sig, detuned, mix);
      filter1 = MoogLadder.ar(sig, freq1 * lfo1.range(1, depth1), res1);
      sig = Decimator.ar(filter1, alias, redux);
      filter2 = MoogLadder.ar(sig, freq2 * lfo2.range(1, depth2), res2);

      sig = Splay.ar(filter2);
      sig = LeakDC.ar(sig);
      sig = XFade2.ar(sig, sig.clip, gain);
      sig = sig * amp * lfo3.range(1, depth3);
      sig = Limiter.ar(sig, 0.8);

      Out.ar(out, (sig).dup);
    }.play(args: [\out, context.out_b], target: context.xg);

    // Add Norns interface hooks
    // \freq, 62.midicps, //Pitch
    this.addCommand("freq", "f", { arg msg;
      synth.set(\freq, msg[1]);
    });

    // \wave, 9, //waveform selector 0 to 89 waveform
    this.addCommand("wave", "f", { arg msg;
      synth.set(\wave, msg[1]);
    });

    // \detune, 1.midiratio, //detune parameter of the second oscillator
    this.addCommand("detune", "f", { arg msg;
      synth.set(\detune, msg[1]);
    });

    // \sub, 1, // 1 takes detune one octave lower, 0 for using detune as it is
    this.addCommand("sub", "f", { arg msg;
      synth.set(\sub, msg[1]);
    });

    // \mix, 0, // Mix for 2 oscillator. -1 is 1st oscillator and 1 for the 2nd oscillator only 0 is the middle
    this.addCommand("mix", "f", { arg msg;
      synth.set(\mix, msg[1]);
    });

    // \freq1, 800, // Cutoff frequency for the 1st filter
    this.addCommand("freq1", "f", { arg msg;
      synth.set(\freq1, msg[1]);
    });

    // \lfo1type1, 0, // LFO of 1st filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
    this.addCommand("lfo1type1", "f", { arg msg;
      synth.set(\lfo1type1, msg[1]);
    });

    // \rate1, 10, // Rate of 1st LFO in Hz
    this.addCommand("rate1", "f", { arg msg;
      synth.set(\rate1, msg[1]);
    });

    // \depth1, 1, // Depth of 1st LFO in Hz, 1 means no modulation, 0 is max
    this.addCommand("depth1", "f", { arg msg;
      synth.set(\depth1, msg[1]);
    });

    // \alias, 44100, // Sample rate reduction in Hz
    this.addCommand("alias", "f", { arg msg;
      synth.set(\alias, msg[1]);
    });

    // \redux, 24, // Bit rate reduction between 0-24 bits
    this.addCommand("redux", "f", { arg msg;
      synth.set(\redux, msg[1]);
    });

    // \freq2, 800, // Cutoff frequency for the 2nd filter
    this.addCommand("freq2", "f", { arg msg;
      synth.set(\freq2, msg[1]);
    });

    // \lfo1type2, 0, // LFO of 2nd filter choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
    this.addCommand("lfo1type2", "f", { arg msg;
      synth.set(\lfo1type2, msg[1]);
    });

    // \rate2, 10, // Rate of 2nd LFO in Hz
    this.addCommand("rate2", "f", { arg msg;
      synth.set(\rate2, msg[1]);
    });

    // \depth2, 1, // Depth of 2nd LFO in Hz, 1 means no modulation, 0 is max
    this.addCommand("depth2", "f", { arg msg;
      synth.set(\depth2, msg[1]);
    });

    // \gain, -1, // Gain stage for distortion kinda effect -1 is clean, 1 is dirty
    this.addCommand("gain", "f", { arg msg;
      synth.set(\gain, msg[1]);
    });

    // \lfo1type3, 0, // LFO of amplitude choose between 3 waveforms 0 for Triangle, 1 for Saw, 2 for Pulse
    this.addCommand("lfo1type3", "f", { arg msg;
      synth.set(\lfo1type3, msg[1]);
    });

    // \rate3, 10, // Rate of 3rd LFO in Hz
    this.addCommand("rate3", "f", { arg msg;
      synth.set(\rate3, msg[1]);
    });

    // \depth3, 1, // Depth of 3rd LFO in Hz, 1 means no modulation, 0 is max
    this.addCommand("depth3", "f", { arg msg;
      synth.set(\depth3, msg[1]);
    });

    this.addCommand("amp", "f", { arg msg;
			synth.set(\amp, msg[1]);
		});
  }

  // Deallocate synth engine
  free {
    synth.free;
  }
}




