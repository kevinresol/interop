package interop;

import haxe.macro.Context;
import haxe.macro.Expr;
import tink.typecrawler.FieldInfo;
import tink.typecrawler.Generator;
import haxe.macro.Type;

using tink.MacroApi;
using tink.CoreApi;

class GenNativizer {
	
	public static function wrap(placeholder:Expr, ct:ComplexType):Function
		return placeholder.func(['value'.toArg(ct)]);
	public static function nullable(e:Expr):Expr
		return macro value;
	public static function string():Expr
		return macro value;
	public static function float():Expr
		return macro value;
	public static function int():Expr
		return macro value;
	public static function dyn(e:Expr, ct:ComplexType):Expr
		throw 0;
	public static function dynAccess(e:Expr):Expr
		throw 0;
	public static function bool():Expr
		return macro value;
	public static function date():Expr
		throw 0;
	public static function bytes():Expr
		throw 0;
	public static function anon(fields:Array<FieldInfo>, ct:ComplexType):Expr {
		final ret:Array<ObjectField> = [];
		for(f in fields) {
			final fname = f.name;
			ret.push({
				field: fname,
				expr: macro {
					final value = value.$fname;
					${f.expr};
				}
			});
		}
		return EObjectDecl(ret).at();
	}
	public static function array(e:Expr):Expr {
		return
			if(Context.defined('java'))
				macro {
					final list = new java.util.ArrayList();
					for(value in value) list.add($e);
					list;
				}
			else
				macro [for(value in value) $e];
	}
	public static function map(k:Expr, v:Expr):Expr
		throw 0;
	public static function enm(constructors:Array<EnumConstructor>, ct:ComplexType, pos:Position, gen:GenType):Expr {
		
		return 
			if(Context.defined('js')) {
				final cases:Array<Case> = [];
				for(ctor in constructors) {
					final typeField:ObjectField = {field: "$type", expr: macro $v{ctor.ctor.name}};
					
					cases.push(switch ctor.fields {
						case []:
							{
								values: [macro $i{ctor.ctor.name}],
								expr: EObjectDecl([typeField]).at(pos),
							}
							
						case params:
							{
								values: {
									final args = params.map(p -> macro $i{p.name});
									[macro $i{ctor.ctor.name}($a{args})];
								},
								expr: {
									final fields = params.map(p -> ({field: p.name, expr: macro interop.Converter.nativize($i{p.name})}:ObjectField));
									EObjectDecl([typeField].concat(fields)).at(pos);
								},
							}
					});
				}
				
				macro (${ESwitch(macro value, cases, null).at(pos)}:Dynamic);
			} else {
				macro value;
			}
	}
	public static function enumAbstract(names:Array<Expr>, e:Expr, ct:ComplexType, pos:Position):Expr
		return macro value;
	public static function rescue(t:Type, pos:Position, gen:GenType):Option<Expr>
		return Some(macro value);
	public static function reject(t:Type):String
		return '[interop] Unsupported type: ' + t.getID();
	public static function shouldIncludeField(c:ClassField, owner:Option<ClassType>):Bool
		return Helper.shouldIncludeField(c, owner);
	public static function drive(type:Type, pos:Position, gen:GenType):Expr {
		return switch type.getMeta().filter(function (m) return m.has(':interop.nativize')) {
			case []:
				gen(type, pos);
			case v:
				final m = v[0].extract(':interop.nativize');
				final f = m[0].params[0];
				macro ($f)(value);
		}
	}
}