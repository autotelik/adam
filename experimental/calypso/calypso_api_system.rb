# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
# Details::   A source/sink of data utilising the Calypos API
#
require 'system'

module TCal
  include_class com.calypso.tk.service
  #.DSConnection
end
 
class CalypsoApiSystem < System

  # TODO - aim here is to open a jar and find relevant classes and methods
  
  def from( project, file, options = {} )
    Java.constants.sort.grep(/Calypso/).each {|c|  puts Java.const_get(c).constants.sort }

#    public static Set<Class> getClassesWhereAnnotationPresent(Class<? extends Annotation> annotation) throws Exception
#  {
#    Set<Class> results = new HashSet<Class>();
#    URLClassLoader loader = (URLClassLoader) AnnotationReader.class.getClassLoader();
#    URL[] urls = loader.getURLs();
#    for (URL url : urls)
#    {
#      String extForm = url.toExternalForm();
#      if (extForm.startsWith("file:") && extForm.endsWith("custom.jar"))
#      {
#        URL jarFileURL = new URL(extForm);
#        File jarFile = new File(jarFileURL.toURI());
#        results.addAll(inspectJar(jarFile, annotation));
#      }
#    }
#    return results;
#  }
#
#    private static Set<Class> inspectJar(File file, Class<? extends Annotation> annotation) throws Exception
#  {
#    Set<Class> results = new HashSet<Class>();
#    ZipInputStream is = new ZipInputStream(new FileInputStream(file));
#    ZipEntry entry;
#    while ((entry = is.getNextEntry()) != null)
#    {
#      if (!entry.isDirectory())
#      {
#        String className = entry.getName();
#        if (className.endsWith(".class"))
#        {
#          className = className.substring(0, className.length() - 6);
#          Class clazz = getClass(className.replaceAll("/", "."), annotation);
#          if (clazz != null)
#          {
#            results.add(clazz);
#          }
#        }
#      }
#    }
#    is.close();
#    return results;
#  }

  end

end
