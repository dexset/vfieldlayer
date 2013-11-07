module engine.history;

interface HistoryDelta
{
    
}

interface HistoryHandler
{
    void add( HistoryDelta );
    void undo();
    void redo();
}
