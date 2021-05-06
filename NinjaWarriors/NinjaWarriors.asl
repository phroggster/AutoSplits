/*
 * phroggie's attempt at a SNES Ninja Warriors (1994) autosplit script for LiveSplit.
 *
 * Copyright (c) 2021  Lee Roach
 * SPDX License: MIT
 *
 *** This is a work in progress and may contain bugs! Patches welcome. ***
 * Available from https://github.com/phroggster/AutoSplits/
 */
state("snes9x") {}
state("snes9x-x64") {}
state("bsnes") {}
state("higan") {}
state("emuhawk") {}

startup {
	const bool defaultDebug = false;
	refreshRate = 0.50d;

	settings.Add("startCharsel", true, "Start: Character Select");
	settings.Add("startIGT", false, "Start: First in-game timer tick");

	settings.Add("boss", true, "Split: Boss Death");
	settings.CurrentDefaultParent = "boss";
	settings.Add("boss1", true, "Stage 1: Gigant");
	settings.Add("boss2", true, "Stage 2: Chainsaw Bull");
	settings.Add("boss3", true, "Stage 3: Yamori");
	settings.Add("boss4", true, "Stage 4: Silverman");
	settings.Add("boss5", true, "Stage 5: Jubei");
	settings.Add("boss6", true, "Stage 6: Phobos & Deimos");
	settings.Add("boss7", true, "Stage 7: Zelos");
	settings.Add("boss8", true, "Stage 8: Banglar");
	settings.CurrentDefaultParent = null;

	settings.Add("rstDeclineCC", true, "Reset: Decline continue");
	settings.SetToolTip("rstDeclineCC", "Reset upon selecting 'No' on the prompt to continue.");
	settings.Add("rstDeath", false, "Reset: Death");
	settings.SetToolTip("rstDeath", "Reset as soon as the player dies. Prevents the use of continues.");
	settings.Add("rstReboot", true, "Reset: Emulator boot");
	settings.SetToolTip("rstReboot", "Reset if the game is restarted.");

	settings.Add("debugging", defaultDebug, "Enable Debugging");
	settings.SetToolTip("debugging", "Enable debugging via DebugView.");

	settings.Add("infosection", false, "---Info---");
	settings.CurrentDefaultParent = "infosection";
	settings.Add("infosection0", false, "Supported emulators: BizHawk (bsnes core) 2.3-2.3.2, 2.6-2.6.1; bsnes 107-107.3, 110-112, 115; Snes9x 1.60; Snes9x-rr 1.60");
	settings.Add("infosection1", false, "Website: https://github.com/phroggster/AutoSplits/");
	settings.CurrentDefaultParent = null;

	if (defaultDebug) print("TNWASL [startup]: LiveSplit AutoSplit script for The Ninja Warriors is starting up.");
}

shutdown {
	refreshRate = 0.5d;
	if (settings["debugging"]) print("TNWASL [shutdown]: AutoSplit script is shutting down. Have a nice day!");
}

exit {
	refreshRate = 0.5d;
	if (settings["debugging"]) print("TNWASL [exit]: Emulator appears to have been closed. Cleaning up.");
}

init {
	refreshRate = 0.50d;

	if (settings["debugging"]) {
		print("TNWASL [init]: AutoSplit script is initializing. Module name is " +
			modules.First().ToString() + " (" + game.ProcessName + ") and memory size is " +
			modules.First().ModuleMemorySize.ToString());
	}

	var states = new Dictionary<int, long> {
		{   9646080,      0x97EE04 }, // Snes9x-rr 1.60
		{  13565952,   0x140925118 }, // Snes9x-rr 1.60 (x64)
		{   9027584,      0x94DB54 }, // Snes9x 1.60
		{  12836864,   0x1408D8BE8 }, // Snes9x 1.60 (x64)
		{  10096640,      0x72BECC }, // bsnes v107
		{  10338304,      0x762F2C }, // bsnes v107.1
		{  47230976,      0x765F2C }, // bsnes v107.2, 107.3
		{ 131543040,      0xA9BD5C }, // bsnes v110
		{  51924992,      0xA9DD5C }, // bsnes v111
		{  52056064,      0xAAED7C }, // bsnes v112
		//{  52477952,      0xB15D7C }, // bsnes v113.1, 114
		{  52477952,      0xB16D7C }, // bsnes v115
		{   7061504, 0x36F11500240 }, // BizHawk 2.3
		{   7249920, 0x36F11500240 }, // BizHawk 2.3.1
		{   6938624, 0x36F11500240 }, // BizHawk 2.3.2
		{   4538368, 0x36F05F94040 }, // BizHawk 2.6.0
		{   4546560, 0x36F05F94040 }, // BizHawk 2.6.1
	};

	long memoryOffset = 0;
	if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset) && memoryOffset != 0) {
		if (game.ProcessName.ToLower().Contains("snes9x")) {
			memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);
		}
	}

	if (memoryOffset == 0) {
		throw new Exception("Can't read WRAM offset. ROM is probably not loaded, or an unsupported emulator is being used.");
	}

	vars.watchers = new MemoryWatcherList {
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0000) { Name = "gsa" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0002) { Name = "gsb" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x01AE) { Name = "tsf" },
		new MemoryWatcher<byte> ((IntPtr)memoryOffset + 0x0278) { Name = "bgm" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18A2) { Name = "hp0" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18A6) { Name = "hp1" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18B2) { Name = "php" },
	};

	if (settings["debugging"]) print("TNWASL [init]: AutoSplit script has been initialized. WRAM appears to be at " + string.Format("0x{0:X}.", memoryOffset));
}

update {
	if (vars.watchers != null && game != null) {
		vars.watchers.UpdateAll(game);
	}
}

start {
	var gsa = vars.watchers["gsa"];
	var gsb = vars.watchers["gsb"];
	var tsf = vars.watchers["tsf"];

	if (gsa.Changed) {
		if (gsa.Current == 5 && refreshRate < 60.0d) {
			refreshRate = 1000/15.0d;
			if (settings["debugging"]) print("TNWASL [start]: Ready to start, increasing refreshRate.");
		} else if (gsa.Current != 4 && gsa.Old == 5) {
			refreshRate = 0.50d;
			if (settings["debugging"]) print("TNWASL [start]: Game state reset, backing down the refreshRate.");
		}
	}

	var charSel = gsa.Current == 5 && settings["startCharsel"] && gsb.Changed && gsb.Current == 2;
	var igtTick = gsa.Current == 4 && settings["startIGT"] && tsf.Old == 1 && tsf.Current == 2;

	if (charSel || igtTick) {
		if (settings["debugging"]) print("TNWASL [start]: Go baby, go!");
		return true;
	}
	return false;
}

reset {
	var gsa = vars.watchers["gsa"];
	var gsb = vars.watchers["gsb"];
	var php = vars.watchers["php"];

	var emuReset = settings["rstReboot"] && gsa.Changed && gsa.Current == 0;
	// Current HP goes to -64 when changing levels to mark a refill anim.
	var playerDead = settings["rstDeath"] && !gsa.Changed && gsa.Current == 4
			&& php.Old > 0 && php.Current <= 0 && php.Current != -64;
	var declineCC = settings["rstDeclineCC"] && gsa.Current == 6 && gsb.Old == 1 && gsb.Current == 3;

	if (emuReset || playerDead || declineCC) {;
		if (settings["debugging"]) print("TNWASL [reset]: " +
			(emuReset ? "Emulator reset" : (playerDead ? "Player died." : (declineCC ? "Continue declined." : "(unknown)."))));
		refreshRate = 0.50d;
		return true;
	}
	return false;
}

split {
	// Phobos and Deimos use enemy slots 1 and 3, every other boss uses enemy slot 0
	var e0dead = (vars.watchers["hp0"].Changed && vars.watchers["hp0"].Current <= 0 && vars.watchers["hp0"].Old > 0);
	var e1dead = (vars.watchers["hp1"].Changed && vars.watchers["hp1"].Current <= 0 && vars.watchers["hp1"].Old > 0);
	var bgm = vars.watchers["bgm"].Current;

	var giga = e0dead && settings["boss1"] && bgm == 0x11;
	var bull = e0dead && settings["boss2"] && bgm == 0x14;
	var yamo = e0dead && settings["boss3"] && bgm == 0x1B;
	var silv = e0dead && settings["boss4"] && bgm == 0x1D;
	var jube = e0dead && settings["boss5"] && bgm == 0x1E;
	var twin = e1dead && settings["boss6"] && bgm == 0x1F;
	var zelo = e0dead && settings["boss7"] && bgm == 0x20;
	var bang = e0dead && settings["boss8"] && bgm == 0x21;

	if (settings["debugging"]) {
		if (giga) print("TNWASL [split]: Boss Gigant has died!");
		if (bull) print("TNWASL [split]: Boss Chainsaw Bull has died!");
		if (yamo) print("TNWASL [split]: Boss Yamori has died!");
		if (silv) print("TNWASL [split]: Boss Silverman has died!");
		if (jube) print("TNWASL [split]: Boss Jubei has died!");
		if (twin) print("TNWASL [split]: Bosses Phobos & Deimos have died!");
		if (zelo) print("TNWASL [split]: Boss Zelos has died!");
		if (bang) print("TNWASL [split]: Boss Banglar has died! Reducing refreshRate.");
	}

	if (bang) refreshRate = 0.50d;
	return (giga || bull || yamo || silv || jube || twin || zelo || bang);
}
