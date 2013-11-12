module engine.core.filter;

import engine.core.action;
public import engine.core.programiface;

interface Filter: Action
{
    void setPI( PIFilter );
}
