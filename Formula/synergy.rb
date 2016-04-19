class Synergy < Formula
  homepage "http://synergy-project.org"
  url "https://github.com/symless/synergy/archive/1.6.3-final.tar.gz"
  sha256 "9740cb12e118c30ce94d4f5029d738198b31fec1814038c8631a7a031dba735d"

  depends_on "cmake" => :build
  depends_on "qt5" => :build

  patch :DATA

  def install
    system "./hm.sh", "conf", "-g1", "--mac-sdk", "#{MacOS.version}", "--mac-identity", "test"
    system "./hm.sh", "build"

    bin.install "bin/synergyc"
    bin.install "bin/synergyd"
    bin.install "bin/synergys"
    bin.install "bin/syntool"

    prefix.install "bin/Synergy.app"
  end
end

# First patch is a fix for building for OSX. There is an error where the default
# generate "Unix Makefile" target is set, it's not getting within OSX setup.
# cf https://github.com/synergy/synergy/issues/3797#issuecomment-87760764

# Second patch is to drop code signing within the build engine.

__END__
diff --git a/ext/toolchain/commands1.py b/ext/toolchain/commands1.py
index d0b0960..ad1fd0b 100644
--- a/ext/toolchain/commands1.py
+++ b/ext/toolchain/commands1.py
@@ -450,7 +450,7 @@ class InternalCommands:
 		if generator.cmakeName.find('Unix Makefiles') != -1:
 			cmake_args += ' -DCMAKE_BUILD_TYPE=' + target.capitalize()
 			
-		elif sys.platform == "darwin":
+		if sys.platform == "darwin":
 			macSdkMatch = re.match("(\d+)\.(\d+)", self.macSdk)
 			if not macSdkMatch:
 				raise Exception("unknown osx version: " + self.macSdk)
@@ -828,7 +828,8 @@ class InternalCommands:
 						if dir.startswith("Qt"):
 							self.try_chdir(target + "/" + dir +"/Versions")
 							self.symlink("5", "Current")
-							self.move("../Resources", "5")
+							if not os.path.exists("5/Resources"):
+								self.move("../Resources", "5")
 							self.restore_chdir()
 
 							self.try_chdir(target + "/" + dir)
@@ -875,7 +876,7 @@ class InternalCommands:
 				frameworkRootDir = "/Library/Frameworks"
 			else:
 				# TODO: auto-detect, qt can now be installed anywhere.
-				frameworkRootDir = "/Developer/Qt5.2.1/5.2.1/clang_64/lib"
+				frameworkRootDir = "/usr/local/Cellar/qt5/5.6.0/lib"
 			
 			target = dir + "/Synergy.app/Contents/Frameworks"
 
@@ -883,9 +884,14 @@ class InternalCommands:
 			for root, dirs, files in os.walk(target):
 				for dir in dirs:
 					if dir.startswith("Qt"):
-						shutil.copy(
-							frameworkRootDir + "/" + dir + "/Contents/Info.plist",
-							target + "/" + dir + "/Resources/")
+						info_plist_file = os.path.join(frameworkRootDir,
+						                               dir,
+						                               "Contents/Info.plist")
+						destdir = os.path.join(target, dir, "Resources/")
+
+						if not os.path.exists(os.path.join(destdir, "Info.plist")):
+							print "Copying {} to {}".format(info_plist_file, destdir)
+							shutil.copy(info_plist_file, destdir)
 
 	def signmac(self):
 		self.loadConfig()
diff --git a/src/gui/src/CommandProcess.h b/src/gui/src/CommandProcess.h
index 3ed935b..a654700 100644
--- a/src/gui/src/CommandProcess.h
+++ b/src/gui/src/CommandProcess.h
@@ -18,6 +18,7 @@
 #ifndef COMMANDTHREAD_H
 #define COMMANDTHREAD_H
 
+#include <QObject>
 #include <QStringList>
 
 class CommandProcess : public QObject
