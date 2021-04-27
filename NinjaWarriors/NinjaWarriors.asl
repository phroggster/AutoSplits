/*
 * phroggie's attempt at a SNES Ninja Warriors (1994) autosplit script for LiveSplit.
 *
 * Copyright (c) 2021  Leland P. Roach
 * SPDX License: MIT
 *
 *** This is a work in progress and may contain bugs! Patches welcome. ***
 * Available from https://github.com/phroggster/AutoSplits/
 */
 
/*
 * Game states / scenes:
 *    0x00 Teito Logo,  0x03 Difficulty Select, 0x04 GamePlay, 0x05 Character Select,
 *    0x06 You're Dead, 0x08 Attract,           0x09 !!GG!!,   0x0B Sound Test
 *    Other values may be seen briefly during boot.
 */

state("snes9x") {}
state("snes9x-x64") {}
state("bsnes") {}
state("higan") {}
state("emuhawk") {}

startup {
	refreshRate = 0.50f;

	vars.defaultDebug = false;

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

	settings.Add("deathReset", false, "Reset: Death");
	settings.SetToolTip("deathReset", "When resets are enabled, checking this box will automatically reset the timer if the player dies. Unchecking this will allow for using continues.");

	settings.Add("debugging", vars.defaultDebug, "Enable Debugging");
	settings.SetToolTip("debugging", "Enable debugging via DebugView.");

	settings.Add("infosection", false, "---Info---");
	settings.CurrentDefaultParent = "infosection";
	settings.Add("infosection0", false, "Supported emulators: BizHawk v2.3, bsnes 107-112, bsnes-plus 5, Higan 106, Snes9x v1.60, Snes9x-rr v1.51 & v1.60");
	settings.Add("infosection1", false, "Website: https://github.com/phroggster/AutoSplits/");
	settings.CurrentDefaultParent = null;

	if (vars.defaultDebug) print("Ninja Warriors ASL [startup]: LiveSplit autosplit script is starting up.");
}

shutdown {
	refreshRate = 66.0f; // reset to the default as set in LiveSplit source code
	if ((vars as System.Collections.Generic.IDictionary<string,object>).ContainsKey("watchers") && vars.watchers != null)
	{
		vars.watchers.ResetAll(); vars.watchers.Clear(); vars.Remove("watchers");
	}
	if (settings["debugging"]) print("Ninja Warriors ASL [shutdown]: LiveSplit autosplit script is shutting down.");
}

init {
	refreshRate = 0.50f;

	if (settings["debugging"]) {
		print("Ninja Warriors ASL [init]: Initializing Ninja Warriors AutoSplitter!");
		if (modules != null && modules.First() != null) {
			print("Ninja Warriors ASL [init]: Module name is " + modules.First().ToString() + " and memory size is " + modules.First().ModuleMemorySize.ToString());
		} else {
			print("Ninja Warriors ASL [init]: Module is null, can't get size. Is the ROM loaded?");
		}
	}

	var states = new Dictionary<int, long> {
		{   9646080,      0x97EE04 },   // Snes9x-rr 1.60
		{  13565952,   0x140925118 },   // Snes9x-rr 1.60 (x64)
		{   9027584,      0x94DB54 },   // Snes9x 1.60
		{  12836864,   0x1408D8bE8 },   // Snes9x 1.60 (x64)
		{  16019456,      0x94D144 },   // higan v106
		{  15360000,      0x8AB144 },   // higan v106.112
		{  10096640,      0x72BECC },   // bsnes v107
		{  10338304,      0x762F2C },   // bsnes v107.1
		{  47230976,      0x765F2C },   // bsnes v107.2/107.3
		{ 131543040,      0xA9BD5C },   // bsnes v110
		{  51924992,      0xA9DD5C },   // bsnes v111
		{  52056064,      0xAAED7C },   // bsnes v112
		{   7061504, 0x36F11500240 },   // BizHawk 2.3
		{   7249920, 0x36F11500240 },   // BizHawk 2.3.1
		{   6938624, 0x36F11500240 },   // BizHawk 2.3.2

		{   9908224,      0x7940FC },   // Snes9x-rr 1.51
		{   9662464,      0x67DAC8 },   // bsnes-plus v05
	};

	long memoryOffset = 0;
	if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset)) {
		memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);
	}

	if (memoryOffset == 0) {
		throw new Exception("Can't read WRAM offset. ROM is probably not loaded or something.");
	}

	vars.watchers = new MemoryWatcherList {
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0000) { Name = "gameState" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0002) { Name = "sceneDatA" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0004) { Name = "sceneDatB" },
		new MemoryWatcher<byte> ((IntPtr)memoryOffset + 0x0278) { Name = "bgmTrack" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18A2) { Name = "enemy0HP" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18A6) { Name = "enemy1HP" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x18B2) { Name = "playerHP" },
	};

	if (settings["debugging"]) {
		print("Ninja Warriors ASL [init]: LiveSplit autosplit script has been initialized. WRAM appears to be at " + string.Format("{0:x}", memoryOffset));
	}
}

exit {
	refreshRate = 66.0f; // Reset to the default as set in LiveSplit source code
	if ((vars as System.Collections.Generic.IDictionary<string,object>).ContainsKey("watchers") && vars.watchers != null) { vars.watchers.ResetAll(); vars.watchers.Clear(); vars.Remove("watchers"); }
	if (settings["debugging"]) print("Ninja Warriors ASL [exit]: emulator appears to have been closed. Cleaning up.");
}

update {
	if (vars.watchers != null && game != null) {
		vars.watchers.UpdateAll(game);
	}
}

start {
	var gme = vars.watchers["gameState"];
	if (gme.Current == 5) {
		if (gme.Changed && gme.Old == 3 && refreshRate < 60) {
			refreshRate = 100;
			if (settings["debugging"]) print("Ninja Warriors ASL [start]: Ready to start, increasing refreshRate to " + refreshRate.ToString() + " fps.");
		}
		if (vars.watchers["sceneDatA"].Changed && vars.watchers["sceneDatA"].Current == 2) {
			if (settings["debugging"]) print("Ninja Warriors ASL [start]: Go baby, go!");
			return true;
		}
	}
	return false;
}

reset {
	var gme = vars.watchers["gameState"];

	// Current HP goes to -64 when changing levels to mark a pending refill.
	var playerDead = settings["deathReset"]
	              && gme.Current == 4 && !gme.Changed
	              && vars.watchers["playerHP"].Old > 0
	              && vars.watchers["playerHP"].Current <= 0
	              && vars.watchers["playerHP"].Current != -64;

	var hostReset = gme.Changed && gme.Old == 4
	             && gme.Current != 3 && gme.Current != 4 && gme.Current != 6;

	if (settings["debugging"]) {
		if (playerDead){
			print("Ninja Warriors ASL [reset]: player appears to have died; HP transitioned from " + vars.watchers["playerHP"].Old.ToString() + " to " + vars.watchers["playerHP"].Current.ToString());
		}
		if (hostReset) {
			print("Ninja Warriors ASL [reset]: emulator appears to have reset. GameMode transitioned from " + gme.Old.ToString() + " to " + gme.Current.ToString());
		}
	}

	if (playerDead || hostReset) {
		if (refreshRate > 0.50f) {
			refreshRate = 0.50f;
			if (settings["debugging"]) print("Ninja Warriors ASL [reset]: game reset, lowering refreshRate to " + refreshRate.ToString() + " fps.");
			return true;
		}
	}
	return (playerDead || hostReset);
}

split {
	// Phobos and Deimos use enemy slots 1 and 3, every other boss uses enemy slot 0
	var enemy0Died = (vars.watchers["enemy0HP"].Changed && vars.watchers["enemy0HP"].Current <= 0 && vars.watchers["enemy0HP"].Old > 0);
	var enemy1Died = (vars.watchers["enemy1HP"].Changed && vars.watchers["enemy1HP"].Current <= 0 && vars.watchers["enemy1HP"].Old > 0);
	var bgm = vars.watchers["bgmTrack"].Current;

	var giga = enemy0Died && settings["boss1"] && bgm == 0x11;
	var bull = enemy0Died && settings["boss2"] && bgm == 0x14;
	var yamo = enemy0Died && settings["boss3"] && bgm == 0x1B;
	var silv = enemy0Died && settings["boss4"] && bgm == 0x1D;
	var jube = enemy0Died && settings["boss5"] && bgm == 0x1E;
	var twin = enemy1Died && settings["boss6"] && bgm == 0x1F;
	var zelo = enemy0Died && settings["boss7"] && bgm == 0x20;
	var bang = enemy0Died && settings["boss8"] && bgm == 0x21;

	if (settings["debugging"]) {
		if (giga) print("Ninja Warriors ASL [split]: Boss Gigant has died!");
		if (bull) print("Ninja Warriors ASL [split]: Boss Chainsaw Bull has died!");
		if (yamo) print("Ninja Warriors ASL [split]: Boss Yamori has died!");
		if (silv) print("Ninja Warriors ASL [split]: Boss Silverman has died!");
		if (jube) print("Ninja Warriors ASL [split]: Boss Jubei has died!");
		if (twin) print("Ninja Warriors ASL [split]: Bosses Phobos & Deimos have died!");
		if (zelo) print("Ninja Warriors ASL [split]: Boss Zelos has died!");
		if (bang) print("Ninja Warriors ASL [split]: Boss Banglar has died!");
	}

	if (bang && refreshRate > 0.50f) {
		refreshRate = 0.50f;
		if (settings["debugging"]) print("Ninja Warriors ASL [split]: reducing refreshRate to " + refreshRate.ToString() + " fps.");
	}
	return (giga || bull || yamo || silv || jube || twin || zelo || bang);
}
