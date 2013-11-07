module engine.filter;

import engine.action;
import engine.programiface;

interface Filter: Action
{
    void setPI( PIFilter );
}
