class RubyImportXSDDialog

  include_class java.awt.GridLayout
  include_class javax::swing::JFileChooser
  include_class javax.swing.BorderFactory

  module JavaFile
    include_class java::io::File
  end

  @@last_dir = 'C:\\SoftwareDev\\JRuby\\ADAM\\test\\fixtures'

  def self.get_import_details

    transfer = {}
    
    chooser = JFileChooser.new
    chooser.setCurrentDirectory( JavaFile::File.new( @@last_dir ) )
    chooser.setFileSelectionMode( JFileChooser::FILES_ONLY )

    panel =  javax.swing.JPanel.new( java.awt.GridLayout.new(0,1) )

    follow_includes_check_box = javax.swing.JCheckBox.new

    follow_includes_check_box.setText("Follow Includes")
    follow_includes_check_box.setFocusable(false)
    follow_includes_check_box.setHorizontalTextPosition(javax.swing.SwingConstants::LEFT)
    follow_includes_check_box.setVerticalTextPosition(javax.swing.SwingConstants::TOP)

    border = javax.swing.BorderFactory.createTitledBorder("Import Options")
    panel.setBorder(border)

    panel.add( follow_includes_check_box )

    label =  javax.swing.JLabel.new("Include Search Path")

    panel.add( label )

    radioGroup =  javax.swing.ButtonGroup.new

    jRadioButton1 =  javax.swing.JRadioButton.new( "Current Dir" )
    jRadioButton2 =  javax.swing.JRadioButton.new( "Current Dir Recursive" )

    panel.add(jRadioButton1)
    radioGroup.add(jRadioButton1)
    panel.add(jRadioButton2)
    radioGroup.add(jRadioButton2)

    chooser.setAccessory(panel)

    chooser.selected_file = JavaFile::File.new(".#{transfer[:export_type]}")
    result = chooser.showOpenDialog @main_view_component

    radioGroup.getElements.each do |b|
      puts b.isSelected, b.getText
    end

    if Java::javax::swing::JFileChooser::APPROVE_OPTION == result
      transfer[:path] = chooser.selected_file.get_path
      
      dir, xsd_file = File.split(transfer[:path])
      transfer[:include_path]  = dir
      transfer[:selected_file] = xsd_file  # chooser.getSelectedFile.get_name
      @@last_dir = dir
      transfer[:follow_includes] = follow_includes_check_box.isSelected
      #puts transfer.inspect
      return transfer
    else
      raise UserCanceledError.new("User canceled export file choice.")
    end
  end
end
