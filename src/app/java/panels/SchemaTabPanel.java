/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * SchemaTabPanel.java
 *
 * Created on 03-May-2009, 10:42:12
 */

package app.java.panels;

/**
 *
 * @author Kuba
 */
public class SchemaTabPanel extends javax.swing.JPanel {

    /** Creates new form SchemaTabPanel */
    public SchemaTabPanel() {
        initComponents();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
  // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
  private void initComponents() {

    schemaToolBar = new javax.swing.JToolBar();
    schemaPane = new javax.swing.JScrollPane();
    schemaTable = new autotelik.swing.SchemaTable();

    schemaToolBar.setRollover(true);

    schemaTable.setModel(new javax.swing.table.DefaultTableModel(
      new Object [][] {

      },
      new String [] {

      }
    ));
    schemaPane.setViewportView(schemaTable);

    javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
    this.setLayout(layout);
    layout.setHorizontalGroup(
      layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
        .addContainerGap()
        .addComponent(schemaToolBar, javax.swing.GroupLayout.DEFAULT_SIZE, 744, Short.MAX_VALUE))
      .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
        .addGroup(layout.createSequentialGroup()
          .addContainerGap()
          .addComponent(schemaPane, javax.swing.GroupLayout.DEFAULT_SIZE, 734, Short.MAX_VALUE)
          .addContainerGap()))
    );
    layout.setVerticalGroup(
      layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
      .addGroup(layout.createSequentialGroup()
        .addComponent(schemaToolBar, javax.swing.GroupLayout.PREFERRED_SIZE, 27, javax.swing.GroupLayout.PREFERRED_SIZE)
        .addContainerGap(647, Short.MAX_VALUE))
      .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
        .addGroup(layout.createSequentialGroup()
          .addGap(57, 57, 57)
          .addComponent(schemaPane, javax.swing.GroupLayout.PREFERRED_SIZE, 593, javax.swing.GroupLayout.PREFERRED_SIZE)
          .addContainerGap(24, Short.MAX_VALUE)))
    );
  }// </editor-fold>//GEN-END:initComponents


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JScrollPane schemaPane;
  private autotelik.swing.SchemaTable schemaTable;
  private javax.swing.JToolBar schemaToolBar;
  // End of variables declaration//GEN-END:variables

}