class Synergy < Formula
  homepage "http://synergy-project.org"
  url "https://github.com/symless/synergy/archive/v1.8.7-final.tar.gz"
  version "1.8.7"
  sha256 "9740cb12e118c30ce94d4f5029d738198b31fec1814038c8631a7a031dba735d"

  depends_on "cmake" => :build
  depends_on "qt5" => :build

  # patch do
  #   url "https://github.com/hyperair/synergy/compare/1.6.3-final...1.6-osx-fixups.patch"
  #   sha256 "e52630fb4151bf9adf4a238efcaba4263fc883352e535ca5f40c976c08cf588d"
  # end

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
