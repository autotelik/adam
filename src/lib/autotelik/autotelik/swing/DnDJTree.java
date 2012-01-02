// Copyright::  Autotelik Media Ltd 2011
// Author ::    Tom Statter
// Date ::      July 2011
// License::    MIT
// About::      A drag and drop Tree based on Swing Hacks book and derived from swingx JXTree
//
package autotelik.swing;

import java.awt.*;
import java.awt.datatransfer.*;
import java.awt.dnd.*;
import java.io.IOException;
import javax.swing.JTree;
import javax.swing.tree.*;
import org.jdesktop.swingx.JXTree;

public class DnDJTree extends JXTree
    implements DragSourceListener, DropTargetListener, DragGestureListener
{
    class DnDTreeCellRenderer extends DefaultTreeCellRenderer
    {

        public Component getTreeCellRendererComponent(JTree tree, Object value, boolean isSelected, boolean isExpanded, boolean isLeaf, int row, boolean hasFocus)
        {
            isTargetNode = value == mDropTargetNode;
            isTargetNodeLeaf = isTargetNode && ((TreeNode)value).isLeaf();
            boolean showSelected = isSelected & (mDropTargetNode == null);
            return super.getTreeCellRendererComponent(tree, value, isSelected, isExpanded, isLeaf, row, hasFocus);
        }

        public void paintComponent(Graphics g)
        {
            super.paintComponent(g);
            if(isTargetNode)
            {
                g.setColor(Color.black);
                if(isTargetNodeLeaf)
                    g.drawLine(0, 0, getSize().width, 0);
                else
                    g.drawRect(0, 0, getSize().width - 1, getSize().height - 1);
            }
        }

        boolean isTargetNode;
        boolean isTargetNodeLeaf;
        boolean isLastItem;
        int BOTTOM_PAD;
        final DnDJTree this$0;

        public DnDTreeCellRenderer()
        {
            super();
            this$0 = DnDJTree.this;
            BOTTOM_PAD = 30;
        }
    }

    class RJLTransferable
        implements Transferable
    {

        public Object getTransferData(DataFlavor df)
            throws UnsupportedFlavorException, IOException
        {
            if(isDataFlavorSupported(df))
                return object;
            else
                throw new UnsupportedFlavorException(df);
        }

        public DataFlavor[] getTransferDataFlavors()
        {
            return DnDJTree.supportedFlavors;
        }

        public boolean isDataFlavorSupported(DataFlavor df)
        {
            return df.equals(DnDJTree.localObjectFlavour);
        }

        Object object;
        final DnDJTree this$0;

        public RJLTransferable(Object o)
        {
            super();
            this$0 = DnDJTree.this;
            object = o;
        }
    }


    public DnDJTree()
    {
        mDropTargetNode = null;
        mDraggedNode = null;
        setCellRenderer(new DnDTreeCellRenderer());
        setModel(new DefaultTreeModel(new DefaultMutableTreeNode("default")));
        mDragSource = new DragSource();
        java.awt.dnd.DragGestureRecognizer dgr = mDragSource.createDefaultDragGestureRecognizer(this, 2, this);
        mDropTarget = new DropTarget(this, this);
    }

    public void dragGestureRecognized(DragGestureEvent dge)
    {
        Point click = dge.getDragOrigin();
        TreePath path = getPathForLocation(click.x, click.y);
        if(path == null)
        {
            System.out.println("not on a node");
            return;
        } else
        {
            mDraggedNode = (TreeNode)path.getLastPathComponent();
            Transferable trans = new RJLTransferable(mDraggedNode);
            mDragSource.startDrag(dge, Cursor.getDefaultCursor(), trans, this);
            return;
        }
    }

    public void dragEnter(DragSourceDragEvent dragsourcedragevent)
    {
    }

    public void dragEnter(DropTargetDragEvent dtde)
    {
        System.out.println("dragEnter");
        dtde.acceptDrag(3);
        System.out.println("accepted dragEnter");
    }

    public void dragExit(DragSourceEvent dragsourceevent)
    {
    }

    public void dragExit(DropTargetEvent droptargetevent)
    {
    }

    public void dragOver(DragSourceDragEvent dragsourcedragevent)
    {
    }

    public void dragOver(DropTargetDragEvent dtde)
    {
        Point dragPoint = dtde.getLocation();
        TreePath path = getPathForLocation(dragPoint.x, dragPoint.y);
        if(path == null)
            mDropTargetNode = null;
        else
            mDropTargetNode = (TreeNode)path.getLastPathComponent();
        repaint();
    }

    public void dropActionChanged(DragSourceDragEvent dragsourcedragevent)
    {
    }

    public void drop(DropTargetEvent droptargetevent)
    {
    }

    public void dragDropEnd(DragSourceDropEvent dsde)
    {
        System.out.println("dragDropEnd()");
        mDraggedNode = null;
        mDropTargetNode = null;
        repaint();
    }

    public void drop(DropTargetDropEvent dtde)
    {
        System.out.println("drop()");
        Point dropPoint = dtde.getLocation();
        TreePath path = getPathForLocation(dropPoint.x, dropPoint.y);
        System.out.println("1");
        boolean dropped = false;
        try
        {
            dtde.acceptDrop(2);
            System.out.println("accepted");
            Object droppedObject = dtde.getTransferable().getTransferData(localObjectFlavour);
            System.out.println("3");
            System.out.println("4");
            MutableTreeNode droppedNode = null;
            if(droppedObject instanceof MutableTreeNode)
            {
                droppedNode = (MutableTreeNode)droppedObject;
                ((DefaultTreeModel)getModel()).removeNodeFromParent(droppedNode);
            } else
            {
                droppedNode = new DefaultMutableTreeNode(droppedObject);
            }
            System.out.println("5");
            DefaultMutableTreeNode dropNode = (DefaultMutableTreeNode)path.getLastPathComponent();
            System.out.println("6");
            if(dropNode.isLeaf())
            {
                DefaultMutableTreeNode parent = (DefaultMutableTreeNode)dropNode.getParent();
                int index = parent.getIndex(dropNode);
                ((DefaultTreeModel)getModel()).insertNodeInto(droppedNode, parent, index);
            } else
            {
                ((DefaultTreeModel)getModel()).insertNodeInto(droppedNode, dropNode, dropNode.getChildCount());
            }
            System.out.println("7");
            dropped = true;
        }
        catch(Exception e)
        {
            System.out.println("EXCEPTION IN drop");
            e.printStackTrace();
        }
        dtde.dropComplete(dropped);
    }

    public void dropActionChanged(DropTargetDragEvent arg0)
    {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    static DataFlavor localObjectFlavour;
    DragSource mDragSource;
    DropTarget mDropTarget;
    TreeNode mDropTargetNode;
    TreeNode mDraggedNode;
    static DataFlavor supportedFlavors[];

    static 
    {
        try
        {
            localObjectFlavour = new DataFlavor("application/x-java-jvm-local-objectref");
        }
        catch(ClassNotFoundException cnfe)
        {
            cnfe.printStackTrace();
        }
        supportedFlavors = (new DataFlavor[] {
            localObjectFlavour
        });
    }
}
