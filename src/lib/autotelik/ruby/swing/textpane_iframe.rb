# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#

class TextPaneIFrame < javax.swing.JInternalFrame

  attr_accessor :jri_text_pane

  def initialize( xpos, ypos, xsize = 600, ysize = 500 )
    super()
    setClosable(true)
    setIconifiable(true)
    setMaximizable(true)
    setResizable(true)
    setTitle("IRB")
    setVisible(true)

    @jri_pane           = javax.swing.JScrollPane.new
    @jri_text_pane      = javax.swing.JTextPane.new

    @jri_pane.setViewportView(@jri_text_pane)

    add(@jri_pane)

    frame_layout = javax.swing.GroupLayout.new(getContentPane())

    getContentPane().setLayout(frame_layout)

    frame_layout.setHorizontalGroup(
      frame_layout.createParallelGroup(javax.swing.GroupLayout::Alignment::LEADING).addGap(0, 266, java.lang.Short::MAX_VALUE).addGroup(frame_layout.createParallelGroup(javax.swing.GroupLayout::Alignment::LEADING).addComponent(@jri_pane, javax.swing.GroupLayout::DEFAULT_SIZE, 530, java.lang.Short::MAX_VALUE))
    )

    frame_layout.setVerticalGroup(
      frame_layout.createParallelGroup(javax.swing.GroupLayout::Alignment::LEADING).addGap(0, 233, java.lang.Short::MAX_VALUE).addGroup(frame_layout.createParallelGroup(javax.swing.GroupLayout::Alignment::LEADING).addComponent(@jri_pane, javax.swing.GroupLayout::DEFAULT_SIZE, 350, java.lang.Short::MAX_VALUE))
    )

    setLocation(xpos, ypos)
    setSize(600, 500)
  end
end
