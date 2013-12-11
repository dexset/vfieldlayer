module ui.except;

class UIException : Exception
{ @safe pure nothrow this( string msg ) { super( msg ); } }
