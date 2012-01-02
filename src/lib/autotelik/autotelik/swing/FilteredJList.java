// Copyright:: Autotelik Media Ltd 2011
// Author ::   Tom Statter
// Date ::     July 2011
// License::   MIT
// About::
//
package autotelik.swing;

import java.io.PrintStream;
import java.util.ArrayList;
import javax.swing.*;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.Document;

public class FilteredJList extends JList
{
    class FilterField extends JTextField
        implements DocumentListener
    {

        public void changedUpdate(DocumentEvent e)
        {
            ((FilterModel)getModel()).refilter();
        }

        public void insertUpdate(DocumentEvent e)
        {
            ((FilterModel)getModel()).refilter();
        }

        public void removeUpdate(DocumentEvent e)
        {
            ((FilterModel)getModel()).refilter();
        }

        final FilteredJList this$0;

        public FilterField(int width)
        {
            super(width);
            this$0 = FilteredJList.this;

            getDocument().addDocumentListener(this);
        }
    }

    class FilterModel extends AbstractListModel
    {

        public void clear()
        {
            items.clear();
            filterItems.clear();
            fireContentsChanged(this, 0, getSize());
        }

        public Object getElementAt(int index)
        {
            if(index < filterItems.size())
                return filterItems.get(index);
            else
                return null;
        }

        public int getSize()
        {
            return filterItems.size();
        }

        public void addElement(Object o)
        {
            items.add(o);
            refilter();
        }

        private void refilter()
        {
            filterItems.clear();
            String term = getFilterField().getText();
            for(int i = 0; i < items.size(); i++)
                if(items.get(i).toString().indexOf(term, 0) != -1)
                    filterItems.add(items.get(i));

            fireContentsChanged(this, 0, getSize());
        }

        ArrayList items;
        ArrayList filterItems;
        final FilteredJList this$0;


        public FilterModel()
        {
            super();
            this$0 = FilteredJList.this;
            items = new ArrayList();
            filterItems = new ArrayList();
        }
    }


    public FilteredJList()
    {
        DEFAULT_FIELD_WIDTH = 20;
        setModel(new FilterModel());
        mFilterField = new FilterField(DEFAULT_FIELD_WIDTH);
    }

    public void setModel(ListModel m)
    {
        if(!(m instanceof FilterModel))
        {
            throw new IllegalArgumentException();
        } else
        {
            super.setModel(m);
            return;
        }
    }

    public void addItem(Object o)
    {
        ((FilterModel)getModel()).addElement(o);
    }

    public void clear()
    {
        System.out.println("in Filtered JLIST clear");
        ((FilterModel)getModel()).clear();
    }

    public JTextField getFilterField()
    {
        return mFilterField;
    }

    private FilterField mFilterField;
    private int DEFAULT_FIELD_WIDTH;
}
