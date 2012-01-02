// Copyright:: Autotelik Media Ltd 2011
// Author ::   Tom Statter
// Date ::     July 2011
// License::   MIT
// About::
//
package autotelik.swing;

import javax.swing.tree.DefaultMutableTreeNode;

public class AdamTreeNode extends DefaultMutableTreeNode
{

    public AdamTreeNode(String name, String klass, int id, boolean leaf)
    {
        super(name, leaf);
        mName = name;
        mKlass = klass;
        mID = id;
    }

    public String toString()
    {
        return mName;
    }

    public int getID()
    {
        return mID;
    }

    public void setID(int mID)
    {
        this.mID = mID;
    }

    public String getKlass()
    {
        return mKlass;
    }

    public void setKlass(String mKlass)
    {
        this.mKlass = mKlass;
    }

    public String getName()
    {
        return mName;
    }

    public void setName(String mName)
    {
        this.mName = mName;
    }

    String mName;
    String mKlass;
    int mID;
}
