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
// Norns version 1.1.0
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
    ~vbuf = Buffer.allocConsecutive(100, context.server, 2048);
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
        mix = (0.0),
        freq1 = 880,
        freq2 = 880,
        res1 = 0.0,
        res2 = 0.0,
        alias = 44100,
        redux = 24,
        rate1 = 1.0,
        rate2 = 0.5,
        rate3 = 0.1,
        depth1 = 1.0,
        depth2 = 0.5,
        depth3 = 0.33,
        lfo1type1 = 1,
        lfo1type2 = 3,
        lfo1type3 = 2;
      
      var osc, oscDetune, pitch, lfo1, lfo2, lfo3, filter1, filter2;

      lfo1 = Select.kr(lfo1type1, [LFCub.kr(rate1), LFTri.kr(rate1), LFSaw.kr(rate1), LFPulse.kr(rate1)]);
      lfo2 = Select.kr(lfo1type2, [LFCub.kr(rate2), LFTri.kr(rate2), LFSaw.kr(rate2), LFPulse.kr(rate2)]);
      lfo3 = Select.kr(lfo1type3, [LFCub.kr(rate3), LFTri.kr(rate3), LFSaw.kr(rate3), LFPulse.kr(rate3)]);

      // Detuned pitch of primary oscillator
      oscDetune = Select.ar(sub, [
        VOsc.ar(wave, (freq * 0.5) * detune),
        VOsc.ar(wave, (freq * 0.25) * detune)
      ]);

      // primary oscillator
      wave = ~vbuf[0].bufnum + wave;
      osc = VOsc.ar(wave, freq);

      osc = XFade2.ar(osc, oscDetune, mix);
      filter1 = MoogLadder.ar(osc, freq1 * lfo1.range(1, depth1), res1);
      osc = Decimator.ar(filter1, alias, redux);
      filter2 = MoogLadder.ar(osc, freq2 * lfo2.range(1, depth2), res2);

      osc = Splay.ar(filter2);
      osc = LeakDC.ar(osc);
      osc = XFade2.ar(osc, osc.clip, gain);
      osc = osc * amp * lfo3.range(1, depth3);
      osc = Limiter.ar(osc, 0.8);

      Out.ar(out, (osc).dup);
    }.play(args: [\out, context.out_b], target: context.xg);

    // Add Norns interface hooks
    this.addCommand("gain", "f", { arg msg;
      synth.set(\gain, msg[1]);
    });

    this.addCommand("amp", "f", { arg msg;
			synth.set(\amp, msg[1]);
		});

    this.addCommand("freq", "f", { arg msg;
      synth.set(\freq, msg[1]);
    });

    this.addCommand("wave", "i", { arg msg;
      synth.set(\wave, msg[1]);
    });

    this.addCommand("detune", "f", { arg msg;
      synth.set(\detune, msg[1]);
    });

    this.addCommand("sub", "i", { arg msg;
      synth.set(\sub, msg[1]);
    });

    this.addCommand("mix", "f", { arg msg;
      synth.set(\mix, msg[1]);
    });

    this.addCommand("alias", "i", { arg msg;
      synth.set(\alias, msg[1]);
    });

    this.addCommand("redux", "f", { arg msg;
      synth.set(\redux, msg[1]);
    });

    this.addCommand("freq1", "f", { arg msg;
      synth.set(\freq1, msg[1]);
    });

    this.addCommand("lfo1type1", "i", { arg msg;
      synth.set(\lfo1type1, msg[1]);
    });

    this.addCommand("rate1", "f", { arg msg;
      synth.set(\rate1, msg[1]);
    });

    this.addCommand("depth1", "f", { arg msg;
      synth.set(\depth1, msg[1]);
    });

    this.addCommand("res1", "f", { arg msg;
      synth.set(\res1, msg[1]);
    });

    this.addCommand("freq2", "f", { arg msg;
      synth.set(\freq2, msg[1]);
    });

    this.addCommand("lfo1type2", "i", { arg msg;
      synth.set(\lfo1type2, msg[1]);
    });

    this.addCommand("rate2", "f", { arg msg;
      synth.set(\rate2, msg[1]);
    });

    this.addCommand("depth2", "f", { arg msg;
      synth.set(\depth2, msg[1]);
    });

    this.addCommand("res2", "f", { arg msg;
      synth.set(\res2, msg[1]);
    });

    this.addCommand("lfo1type3", "i", { arg msg;
      synth.set(\lfo1type3, msg[1]);
    });

    this.addCommand("rate3", "f", { arg msg;
      synth.set(\rate3, msg[1]);
    });

    this.addCommand("depth3", "f", { arg msg;
      synth.set(\depth3, msg[1]);
    });
  }

  // Deallocate synth engine
  free {
    synth.free;
  }
}



