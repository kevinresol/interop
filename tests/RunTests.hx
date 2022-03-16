package ;

class RunTests {

  static function main() {
    
    trace(interop.Converter.nativize(Foo(1)));
    trace(interop.Converter.nativize(Bar));
    final v = interop.Converter.nativize(Baz(Foo(1)));
    
    final c = java.lang.Class.forName("haxe.root.MyEnum$Baz");
    
    trace((cast v:java.lang.Object).getClass());
    trace(c.isInstance(v));
    trace(c.isInstance("true"));
    
    travix.Logger.println('it works');
    travix.Logger.exit(0); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
}

enum MyEnum {
  Foo(int:Int);
  Bar;
  Baz(nested:MyEnum);
}