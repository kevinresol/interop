package interop;

import tink.macro.BuildCache;
import tink.typecrawler.Crawler;

using tink.MacroApi;

class Nativizer {
	public static function build() {
		return BuildCache.getType('interop.Nativizer', (ctx:BuildContext) -> {
			final name = ctx.name;
			final ct = ctx.type.toComplex();
			
			
			final ret = Crawler.crawl(ctx.type, ctx.pos, GenNativizer);
			
			final def = macro class $name extends interop.Nativizer.NativizerBase {
				public inline function nativize(value:$ct) {
					return ${ret.expr}
				}
			}
    		def.fields = def.fields.concat(ret.fields);
			
			def.pack = ['interop'];
			
			return def;
			
		});
	}
}