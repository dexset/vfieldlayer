module engine.history;

import engine.item;

import desmath.types.rect;

interface HistoryItem : Item
{
    @property irect delta() const;

    void apply();
    void rollback();
}

interface HistoryHandler
{
    void push( HistoryItem );

    bool hasUndo();
    bool hasRedo();

    void undo();
    void redo();
}
