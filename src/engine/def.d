module engine.def;

public import derelict.sdl2.sdl;
public import derelict.opengl3.gl3;
public import derelict.devil.il;

public import desgui;
public import desutil;
public import desmath.types.vector;

class AppException: Exception 
{ @safe pure nothrow this( string msg ){ super( msg ); } }
