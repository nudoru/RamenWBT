package ramen.common {
	
	import com.nudoru.utils.RandomLatin;
	import ramen.common.LogicManager; 
	
	public class AutoContent {
		
		private var _Latin	:RandomLatin;
		
		public function AutoContent():void { }
		
		public function applyContentFunction(s:String):String {
			if (s.indexOf("getlatin") == 0) {
				var l:RandomLatin = new RandomLatin();
				return l.generateLatinString(s);
			}
			if (hasVariable(s)) {
				s = processVariables(s);
			}
			return s;
		}
		
		private function hasVariable(s:String):Boolean {
			if (s.indexOf("{$") > -1) return true;
			return false;
		}
		
		private function processVariables(s:String):String {
			while (hasVariable(s)) {
				s = replaceVariable(s);
			};
			return s;
		}
		
		// function provided by Juan Pablo Califano on Flash_Tiger list
		/*var test:String = "Hello there {$name}, how is the {$noun} today?";

		var replacementMap:Object     = {
		   name    :    "YOUR_NAME_HERE",
		   noun    :    "YOUR_NOUN_HERE"
		};

		trace(StringUtils.replacePlaceholders(test,replacementMap));*/
		
		/*public static function replacePlaceholders(input:String,replacementMap:Object):String {
		   // '{$', followed by any char except '}', ended by '}'
		   var pattern:RegExp = /{\$([^\}]*)\}/g;
		   return input.replace(pattern,function():String {
			   return replaceEntities(arguments,replacementMap);
		   });
       }

       private static function replaceEntities(regExpArgs:Array,map:Object):String {
           var entity:String         = String(regExpArgs[0]);
           var entityBody:String     = String(regExpArgs[1]);
           return (map[entityBody]) ? map[entityBody] : entity;
       }*/
		
		private function replaceVariable(s:String):String {
			var fidx:int = s.indexOf("{$");
			var lidx:int = s.indexOf("$}")+2;
			var varname:String = s.substring(fidx, lidx);
			var vartext:String = getVariableText(varname);
			return s.split(varname).join(vartext);
		}
		
		// n format = {$varname$}
		private function getVariableText(n:String):String {
			var v:String = n.substring(2, n.length - 2);
			return LogicManager.getInstance().getVariableValue(v);
		}
	}
	
}