/**
 *
 * @author Tom Statter
 *
# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     May 2009
# License::   MIT ?
#
*/

package app.java.panels;

import javax.swing.SwingWorker;
import java.awt.Color;
import java.awt.Font;
import java.awt.Insets;
import java.awt.Rectangle;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.text.BadLocationException;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import org.jruby.Ruby;
import org.jruby.RubyInstanceConfig;
import org.jruby.internal.runtime.ValueAccessor;

import autotelik.swing.TextAreaReadline;

public class JRubyInteractiveWorker extends SwingWorker<JTextPane, String> {

    private final JTextPane txtpane;
    private final TextAreaReadline tar;
    private final RubyInstanceConfig config;
    private final Ruby runtime;

    public JRubyInteractiveWorker(JTextPane pane) {
        txtpane = pane;
        tar = new TextAreaReadline(txtpane, "ADAM Irb Console" + " \n\n");

        config = new RubyInstanceConfig() {
            {
                setOutput(new PrintStream(tar.getOutputStream()));
                setError(new PrintStream(tar.getOutputStream()));
                setObjectSpaceEnabled(true);
            }
        };

        runtime = Ruby.newInstance(config);
    }

    public JTextPane getTextpane() {
        return txtpane;
    }

    public TextAreaReadline getTar() {
        return tar;
    }

    @Override
    protected JTextPane doInBackground() throws Exception {

        final JTextPane textPane = txtpane;

        textPane.setMargin(new Insets(10, 10, 10, 10));
        textPane.setCaretColor(new Color(0xa4, 0x00, 0x00));
        textPane.setBackground(new Color(0xf2, 0xf2, 0xf2));
        textPane.setForeground(new Color(0xa4, 0x00, 0x00));

        // From core/output2/**/AbstractOutputPane
        Integer i = (Integer) UIManager.get("customFontSize"); //NOI18N
        int size;
        if (i != null) {
            size = i.intValue();
        } else {
            Font f = (Font) UIManager.get("controlFont"); // NOI18N
            size = f != null ? f.getSize() : 11;
        }
        textPane.setFont(new Font("Monospaced", Font.PLAIN, size)); //NOI18N

        runtime.getGlobalVariables().defineReadonly("$$", new ValueAccessor(runtime.newFixnum(System.identityHashCode(runtime))));
        runtime.getLoadService().init(new ArrayList());

        tar.hookIntoRuntimeWithStreams(runtime);

        runtime.evalScriptlet("require 'irb'; require 'irb/completion'; IRB.start");

        // [Issue 91208]  avoid of putting cursor in IRB console on line where is not a prompt
        textPane.addMouseListener(new MouseAdapter() {

            @Override
            public void mouseClicked(MouseEvent ev) {
                final int mouseX = ev.getX();
                final int mouseY = ev.getY();
                // Ensure that this is done after the textpane's own mouse listener
                SwingUtilities.invokeLater(new Runnable() {

                    public void run() {
                        // Attempt to force the mouse click to appear on the last line of the textPane input
                        int pos = textPane.getDocument().getEndPosition().getOffset() - 1;
                        if (pos == -1) {
                            return;
                        }

                        try {
                            Rectangle r = textPane.modelToView(pos);

                            if (mouseY >= r.y) {
                                // The click was on the last line; try to set the X to the position where
                                // the user clicked since perhaps it was an attempt to edit the existing
                                // input string. Later I could perhaps cast the textPane document to a StyledDocument,
                                // then iterate through the document positions and locate the end of the
                                // input prompt (by comparing to the promptStyle in TextAreaReadline).
                                r.x = mouseX;
                                pos = textPane.viewToModel(r.getLocation());
                            }

                            textPane.getCaret().setDot(pos);
                        } catch (BadLocationException ble) {
                            // TOM Exceptions.printStackTrace(ble);
                        }
                    }
                });
            }
        });

        System.out.println("OUT JRubyInteractiveWorker - doInBackground");
        return txtpane;
    }

    @Override
    protected void process(final List<String> chunks) {
        final SimpleAttributeSet style = new SimpleAttributeSet();
        StyleConstants.setForeground(style, new Color(0x66, 0x33, 0xff));

        for (String txt : chunks) {
            tar.append(txt, style);
        }
    }
}