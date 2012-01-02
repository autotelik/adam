// EXAMPLE BY T STATTER - HOW TO RUN A JRUBY TASK FROM A JAVA APPLICATION
// LIKE Calypso


//package calypso;
//
//import com.calypso.tk.service.DSConnection;
//import com.calypso.tk.core.*;
//
//import java.util.ArrayList;
//
//
//import org.jruby.Ruby;
//import org.jruby.RubyRuntimeAdapter;
//import org.jruby.javasupport.JavaEmbedUtils;
//
//
//public class ScheduledTaskScriptLoader {
//
//  protected static boolean runScript(String requires, String script, DSConnection ds)
//  {
//    if( ScheduledTaskScriptLoader.setJRubyProperties() == false) {
//         return false;
//    }
//
//    Log.info(Log.INFO, "Starting scheduled Task Script : " + script);
//
//    Ruby runtime = JavaEmbedUtils.initialize(new ArrayList());
//    RubyRuntimeAdapter evaler = JavaEmbedUtils.newRuntimeAdapter();
//
//    String env  = ds.getDataServerName();
//    String pwd  = ds.getPasswd();
//    String user = ds.getUser();
//    String host = ds.getHostName();
//    String port = Integer.toString( Defaults.getRMIRegistryPort() );        // do not quote in script
//
//    String bootRuby = "require 'java'\n" +
//                          "  $LOAD_PATH << File.join(ENV['CALYPSO_HOME'], 'jars')\n" +
//                          "  require 'calypso'\n" +
//                          "  require 'log4j'\n" +
//                          "  require 'rubygems'\n" +
//                          "  module RC\n" +
//                          "      include_package 'com.calypso.tk.core'\n" +
//                          "  end\n" +
//                          "  begin\n" +
//                             requires +  "\n" +
//                          "    args = ['-rmiPort', "     + port + ",'-env', '" + env + "']\n" +
//                          "    args << '-user' << '"     + user + "'\n" +
//                          "    args << '-password' << '" + pwd + "'\n" +
//                          "    args << '-host' << '"     + host + "'\n" +
//                          "    DataServer.instance.connect( args, 'SchedTaskScript' ) \n" +
//                             script  + "\n" +
//                          "    DataServer.instance.disconnect\n" +
//                          "  rescue LoadError => e\n" +
//                          "     RC::Log.error(RC::Log.ERROR, 'Problem loading script' ) \n" +
//                          "     e.backtrace.each {|x| RC::Log.error(RC::Log.ERROR, x.inspect ) } \n" +
//                          "     raise Exception.new('Caught LoadError during script startup')\n" +
//                          "  rescue Exception => e\n" +
//                          "     RC::Log.error(RC::Log.ERROR, 'Problem running script' ) \n" +
//                          "     e.backtrace.each {|x| RC::Log.error(RC::Log.ERROR, x.inspect ) } \n" +
//                          "     raise Exception.new('Caught exception during script execution')\n" +
//                          "  end\n";
//
//     try {
//        evaler.eval(runtime, bootRuby );
//     }
//     catch( Exception e) {
//        JavaEmbedUtils.terminate(runtime);
//        Log.error(Log.ERROR, "Script " + script + " failed during eval");
//        Log.error(Log.ERROR, "error cause:" + e.getCause());
//        e.printStackTrace();
//        return false;
//    }
//
//     Log.info(Log.INFO, "Scheduled Task Script : " + script + " Finished");
//     JavaEmbedUtils.terminate(runtime);
//     return true;
//  }
//
//  protected static boolean setJRubyProperties()
//  {
//     try {
//            String jhome = Defaults.getProperty("JRUBY_HOME");
//
//            System.setProperty("jruby.base", jhome);
//            System.setProperty("jruby.home", jhome);
//            System.setProperty("jruby.lib", jhome + "\\lib");
//            System.setProperty("jruby.shell", "cmd.exe");
//            System.setProperty("jruby.script", "jruby.bat");
//        } catch (Exception e) {
//            Log.error(Log.ERROR, "Property JRUBY_HOME must be set to jruby interpreter home");
//            return false;
//        }
//     return true;
//  }
//}
