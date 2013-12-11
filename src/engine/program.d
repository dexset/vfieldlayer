module engine.program;

public import engine.core;

import engine.workspace;
import engine.imagelayer;

import engine.brush;

class ProgramUserException: ProgramException
{
    enum Reason
    {
        NONE,
        NONAME,
        NOSIZE,
        NOTYPE,
        NOCURWS
    }

    Reason reason;

    @safe pure nothrow this( string msg, Reason r=Reason.NONE )
    {
        super( msg );
        reason = r;
    }
}

class VFProgram: Program
{
protected:
    Workspace[] wslist;
    Workspace curws;

    Tool[] toollist;
    Tool curtool;

    void createLayer( Variant[string] set )
    {
        if( curws is null )
            throw new ProgramUserException( "no current workspace", ProgramUserException.Reason.NOCURWS );

        auto name = set["name"].get!string;
        if( "size" !in set )
            throw new ProgramUserException( "no size", ProgramUserException.Reason.NOSIZE );
        if( "type" !in set )
            throw new ProgramUserException( "no type", ProgramUserException.Reason.NOTYPE );

        auto sz = set["size"].get!imsize_t;
        auto tp = set["type"].get!ImageType;

        curws.layers ~= new ImageLayer( name, sz, tp );
    }

    void createWorkspace( Variant[string] set )
    {
        auto name = set["name"].get!string;
        if( "size" !in set )
            throw new ProgramUserException( "no size", ProgramUserException.Reason.NOSIZE );

        auto sz = set["size"].get!imsize_t;

        curws = new Workspace( name, sz );
        wslist ~= curws;
    }

public:

    this()
    {
        curtool = new TestColorBrush({ return cast(WSData)curws; });
        toollist ~= curtool;
    }

    Item[] getList( ItemType it )
    {
        Item[] list;
        final switch(it)
        {
            case ItemType.TOOL:
                foreach( tool; toollist )
                    list ~= tool;
                break;
            case ItemType.LAYER:
                if( curws !is null )
                    foreach( layer; curws.layers )
                        list ~= layer;
                break;
            case ItemType.WORKSPACE:
                foreach( ws; wslist )
                    list ~= ws;
                break;
        }
        return list;
    }

    Setting[] getSettings( SettingType st )
    {
        final switch(st)
        {
            case SettingType.TOOL:
                return curtool.getSettings();
            case SettingType.LAYER:
                if( curws !is null )
                    return curws.getSelectLayersSettings();
                else return [];
            case SettingType.WORKSPACE:
                if( curws !is null )
                    return curws.getSettings();
                else return [];
        }
    }

    void clickOnItem( ItemType it, Item item )
    {
        final switch(it)
        {
            case ItemType.TOOL:
                foreach( tool; toollist )
                    if( tool == item )
                    {
                        curtool.select = false;
                        curtool = tool;
                        curtool.select = true;
                    }
                break;
            case ItemType.LAYER:
                if( curws !is null )
                    curws.selectLayer( cast(Layer)item );
                break;
            case ItemType.WORKSPACE:
                curws = null;
                foreach( ws; wslist )
                    if( ws == item )
                    {
                        curws = ws;
                        curtool.deactivate();
                        curtool.activate();
                    }
                break;
        }
    }

    void create( CreateType ct, Variant[string] set )
    {
        if( "name" !in set )
            throw new ProgramUserException( "no name", ProgramUserException.Reason.NONAME );
        final switch(ct)
        {
            case CreateType.LAYER:
                if( curws is null )
                    createWorkspace( set );
                createLayer( set );
                break;
            case CreateType.WORKSPACE:
                createWorkspace( set );
                break;
        }
    }

    void mouse_eh( in vec2 mpos, in DiMouseEvent me )
    { 
        curtool.mouse_eh( mpos+curws.offset, me ); 
    }

    void keyboard_eh( in vec2 mpos, in DiKeyboardEvent ke )
    { 
        curtool.keyboard_eh( mpos+curws.offset, ke ); 
    }
}
