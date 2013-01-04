# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
class RubyMessageDialog

  java_import javax.swing.JOptionPane

  def self.show( msg )
    JOptionPane.showMessageDialog(nil, msg)
  end

 end

class RubyInputDialog

  java_import javax.swing.JOptionPane

  def self.show( msg, title = "Input Dialog" )
    JOptionPane.showInputDialog(nil, msg, title, JOptionPane::QUESTION_MESSAGE)
  end

end