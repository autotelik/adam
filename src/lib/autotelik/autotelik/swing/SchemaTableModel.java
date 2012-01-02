// Copyright:: Autotelik Media Ltd 2011
// Author ::   Tom Statter
// Date ::     July 2011
// License::   MIT
// About::
//
package autotelik.swing;

import java.util.Vector;
import javax.swing.table.DefaultTableModel;

public class SchemaTableModel extends DefaultTableModel
{

    public SchemaTableModel()
    {
    }

    public Vector getColumnIdentifiers()
    {
        return columnIdentifiers;
    }
}
