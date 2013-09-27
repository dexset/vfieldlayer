#!/bin/rdmd

import dbuild;

enum ArgsList DerelictLibs = 
{
    "-L-lDerelict",
    [
    "GL3",
    "FT",
    "SDL2",

    "Util",
    ]
};

enum ArgsList ImportDirs = 
{
    "-I",
    [
    "./src",
    "../Derelict3/import",
    "./desutil/import",
    "./desmath/import",
    "./desgl/import",
    "./desgui/import",
    ]
};

string[] filedirs =
    [
    "./src",
    "./desutil/import",
    "./desmath/import",
    "./desgl/import",
    "./desgui/import",
    ];

enum ArgsList LinkerFlags = 
{
    "-L",
    [
    "-L../Derelict3/lib/dmd",
    "-ldl",
    ]
};

string projectname = "vfieldlayer";

static this()
{
    sm_flags ~= [ ImportDirs, LinkerFlags, DerelictLibs ];
}

int main( string[] args )
{
    string bindir = "?bin";
    string[] flags;
    string[] optflags;
    bool release = false;

    string[] debugflags;
    string[] versionflags;

    string[] dargs = args.dup;
    bool unittestflag = false;

    getopt( dargs,
            config.passThrough,
            "name|n",    &projectname,
            "bindir",    &bindir,
            "debug",     &debugflags,
            "version",   &versionflags,
            "unittest",  &unittestflag,
            "flag",      &optflags,
            "release|O", &release,
          );

    foreach( of; optflags ) flags ~= of;
    if( unittestflag ) flags ~= "-unittest";
    if( debugflags.length ) flags ~= "-gc";
    foreach( df; debugflags ) flags ~= "-debug=" ~ df;
    foreach( vf; versionflags ) flags ~= "-version=" ~ vf;

    stdout.writeln( "build.d flags: " );
    stdout.writeln( "   output:   ", projectname );
    stdout.writeln( "   bindir:   ", bindir );
    stdout.writeln( "   flags:    ", flags );

    bool cine = false;
    if( bindir[0] == '?' )
    {
        bindir = bindir[ 1 .. $ ];
        cine = true;
    }
    if( !checkDir( bindir, cine ) ) return 1;

    if( !submoduleBuild( args ) ) 
    {
        foreach( alf; sm_flags )
            flags ~= alf.list;

        flags ~= findFiles( filedirs ).list;

        foreach( alf; sm_files )
            flags ~= alf.list;

        return buildBin!buildDExecCmd( bnp( bindir, projectname ), 
                                            flags, release );
    }
    return 1;
}
