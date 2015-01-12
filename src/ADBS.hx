package;

import haxe.Http;
import haxe.Json;
import mcli.CommandLine;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

typedef ScreenList = {
	var items:Array<Screen>;
}

typedef Screen = {
	var name:String;
	var w:Int;
	var h:Int;
	var d:Null<Float>;
	var ppi:Null<Float>;
	var dppx:Null<Float>;
}

/**
 * adbs (adb screen)
 * 
 * Sets the screen density and size via adb with the provided device name.
 * 
 * List maintained by dpi.lv
 * 
 * Usage: adbs DEVICE NAME
 * 
 * Examples:
 * 
 *   adbs nexus 7 13  Sets the density and size to the 2013 edition of the Nexus 7.
 *   adbs reset       Resets the density and size.
 *   adbs --help      Shows help.
 */
class ADBS extends CommandLine {
	
	static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new ADBS());
	}
	
	function info(log:Dynamic) {
		Sys.println(""+log);
	}
	
	static var REMOTE_LIST = "https://raw.githubusercontent.com/LeaVerou/dpi/gh-pages/screens.json";
	static var LIST_PATH = "screens.json";
	
	/**
	 * Dry run - don't execute any adb commands.
	 * 
	 * @alias d
	 */
	public var dry:Bool = false;
	
	/**
	 * Print this help message.
	 * 
	 * @alias h
	 */
	public function help() {
		Sys.println(this.showUsage());
		Sys.exit(0);
	}
	
	/**
	 * Update the list from the default remote server.
	 * 
	 * @alias u
	 */
	public function update() {
		info('Downloading from $REMOTE_LIST');
		var contents = Http.requestUrl(REMOTE_LIST);
		var list = parse(contents);
		info('Updated list (${list.items.length} screens)');
		File.saveContent(LIST_PATH, contents);
	}
	
	public function runDefault(varArgs:Array<String>) {
		var name = varArgs.join(" ");
		var tn = StringTools.trim(name);
		switch (tn) {
			case "reset":
				exec("adb", 'shell wm density reset'.split(" "));
				exec("adb", 'shell wm size reset'.split(" "));
				Sys.exit(0);
			case "":
				help();
				Sys.exit(1);
		}
		if (!hasList()) update();
		var list = parse(File.getContent(LIST_PATH));
		var nameLowerWords = name.toLowerCase().split(" ");
		var found = [for (screen in list.items) if ([for (word in nameLowerWords) if (screen.name.toLowerCase().indexOf(word) != -1) word].length == nameLowerWords.length) screen];
		if (found.length <= 0) {
			info('No screens found for "${name}"');
			Sys.exit(2);
		}
		if (found.length > 1) {
			info('Found ${found.length} screens');
			for (screen in found) info('\t${screen.name}');
			Sys.exit(3);
		}
		var s = found[0];
		var w = s.w;
		var h = s.h;
		var ppi = s.ppi != null ? s.ppi : Math.round(Math.sqrt(w*w+h*h)/s.d);
		info('${s.name} - ${w} x ${h} @ ${ppi}');
		exec("adb", 'shell wm density $ppi'.split(" "));
		exec("adb", 'shell wm size ${w}x${h}'.split(" "));
	}
	
	function exec(cmd:String, args:Array<String>) {
		info((dry ? "[dry run] " : "") + cmd + " " + args.join(" "));
		if (dry) return;
		Sys.command(cmd, args);
	}
	
	private function hasList() {
		return FileSystem.exists(LIST_PATH);
	}
	
	
	function parse(json:String) {
		var list:ScreenList = Json.parse('{ "items": $json }');
		if (list == null) throw "Unable to parse list";
		return list;
	}
	
}