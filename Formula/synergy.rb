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
index d0b0960..00aaa3a 100644
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
@@ -875,7 +875,7 @@ class InternalCommands:
 				frameworkRootDir = "/Library/Frameworks"
 			else:
 				# TODO: auto-detect, qt can now be installed anywhere.
-				frameworkRootDir = "/Developer/Qt5.2.1/5.2.1/clang_64/lib"
+				frameworkRootDir = "/usr/local/Cellar/qt5/5.6.0/lib"
 			
 			target = dir + "/Synergy.app/Contents/Frameworks"
 
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
