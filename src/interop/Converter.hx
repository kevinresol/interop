package interop;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
using tink.MacroApi;
#end

class Converter {
	public static macro function nativize(e:Expr) {
		final ct = Context.typeof(e).toComplex();
		return macro @:pos(e.pos) new interop.Nativizer<$ct>().nativize($e);
	}
}