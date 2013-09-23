module dbuild;

public import std.stdio : stdout, stderr;
public import std.process: executeShell;
public import std.string : format, join;
public import std.getopt;
public import std.file, std.path;

string bnp( string[] pp... )
{ return buildNormalizedPath( pp ); }

class BuildException: Exception { this( string msg ) { super(msg); } }

bool checkDir( string dir, bool createIfNotExists=false )
{
    if( dir.exists )
    {
        if( !dir.isDir )
        {
            stderr.writefln( "\nCheck '%s' dir fails: file exist but isn't a dir\n", dir );
            return false;
        }

        return true;
    }
    else if( createIfNotExists )
    {
        mkdir( dir );
        return true;
    }
    else 
    {
        stderr.writefln( "\nCheck '%s' dir fails: dir not exist\n", dir );
        return false;
    }
}

struct ArgsList
{
    string pre;
    string[] args;

    @property string[] list() const
    {
        string[] ret;
        foreach( arg; args )
            ret ~= pre ~ arg;
        return ret;
    }
}

struct BuildResult
{
    bool success = false;
    ArgsList[] flags, files;
}

auto findFiles( string[] dirs, string ext = "*.{d}" )
{
    string[] ret;

    foreach( dir; dirs )
    {
        auto flist = dirEntries( dir, ext, SpanMode.breadth );
        foreach( f; flist ) ret ~= f.name;
    }

    return ArgsList( "", ret );
}

auto buildDExecCmd( string fullname, string[] flags, bool release=false )
{
    string cmplopt = "\\\n";
    foreach( of; flags ) cmplopt ~= of ~ " \\\n";

    string compillerfmt;
    string optimization;

    version(DigitalMars)
    {
        compillerfmt = "dmd %s \\\n -of%s ";
        optimization = "-O -release -inline -property -wi";
    }
    else version(GNU)
    {
        compillerfmt = "gdc %s -o %s ";
        optimization = "-s -O3 -Wall";
    }
    else version(LDC)
    {
        compillerfmt = "ldc2 %s -of%s ";
        optimization = "-O -release -enable-inlining -property -w";
    }

    if( release ) cmplopt ~= optimization;

    return format( compillerfmt, cmplopt, fullname );
}

string buildCObjCmd( string fullname, string[] flags, bool release=false )
{
    string cmpl = "gcc ";
    foreach( f; flags ) cmpl ~= f ~ " ";
    cmpl ~= " -o " ~ fullname;
    return cmpl;
}

string buildCLibCmd( string fullname, string[] flags, bool r )
{
    if( flags.length > 1 ) 
        throw new Exception( "many flags for buildCLibCmd" );
    return "ar rcs " ~ fullname ~ " " ~ flags[0];
}


int buildBin(alias buildcmdfnc)( string outfile, string[] flags, bool release=false )
    if( is( typeof( buildcmdfnc( "", [], false ) == string ) ) )
{
    string buildCmd = buildcmdfnc( outfile, flags, release );

    stdout.writefln( "Building '%s'. Build command:\n%s", outfile, buildCmd );

    auto buildProc = executeShell( buildCmd );

    if( buildProc.output )
        stdout.writefln( "Building '%s' output:\n%s", 
                outfile, buildProc.output );

    if( buildProc.status != 0 )
    {
        stderr.writefln( "\nBuild '%s' failed!\n", outfile );
        return 1;
    }
    else stdout.writefln( "  successed" );
    return 0;
}

alias BuildResult delegate( string[] ) subbuild;

subbuild[string] submodules;

ArgsList[] sm_flags;
ArgsList[] sm_files;

int submoduleBuild( string[] args )
{
    foreach( name, func; submodules )
    {
        stdout.writefln( "Building submodule '%s'...", name );
        auto br = func( args );
        if( !br.success )
        {
            stderr.writefln( "\nBuild submodule '%s' failed!\n", name );
            return 1;
        }
        sm_flags ~= br.flags;
        sm_files ~= br.files;
        stdout.writefln( "Build submodule '%s' success!\n", name );
    }

    stdout.writefln( "Build all submodules success!\n" );
    return 0;
}
