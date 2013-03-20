VER: 0.1.0 Alpha

HOW TO INSTALL:

1. Copy soap.php file to your MiniShowcase home folder 
2. Edit soap.php and change the pathname to the proper one
3. Set write permissions for the apache user (or whatever it's in your case)
   to the 'galleries' folder (the folder where you keep your photos)
4. Download NuSoap library (http://sourceforge.net/projects/nusoap/) and put it 
   in MiniShowcase home folder
5. If you don't have it already - download Java JRE v1.5 or higher
6. Enjoy!


http://minimanage.sourceforge.net

========================
BUILD OUTPUT DESCRIPTION
========================

When you build an Java application project that has a main class, the IDE
automatically copies all of the JAR
files on the projects classpath to your projects dist/lib folder. The IDE
also adds each of the JAR files to the Class-Path element in the application
JAR files manifest file (MANIFEST.MF).

To run the project from the command line, go to the dist folder and
type the following:

java -jar "MiniManage.jar" 

To distribute this project, zip up the dist folder (including the lib folder)
and distribute the ZIP file.

Notes:

* If two JAR files on the project classpath have the same name, only the first
JAR file is copied to the lib folder.
* If the classpath contains a folder of classes or resources, none of the
classpath elements are copied to the dist folder.
* If a library on the projects classpath also has a Class-Path element
specified in the manifest,the content of the Class-Path element has to be on
the projects runtime path.
* To set a main class in a standard Java project, right-click the project node
in the Projects window and choose Properties. Then click Run and enter the
class name in the Main Class field. Alternatively, you can manually type the
class name in the manifest Main-Class element.
