require 'formula'

class Opencv < Formula
  homepage 'http://opencv.org/'
  url 'http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.5/opencv-2.4.5.tar.gz'
  sha1 '9e25f821db9e25aa454a31976ba6b5a3a50b6fa4'

  option '32-bit'
  option 'with-qt',  'Build the Qt4 backend to HighGUI'
  option 'with-tbb', 'Enable parallel code in OpenCV using Intel TBB'
  option 'without-opencl', 'Disable gpu code in OpenCV using OpenCL'

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'numpy' => :python
  depends_on :python

  depends_on 'eigen'   => :optional
  depends_on 'libtiff' => :optional
  depends_on 'jasper'  => :optional
  depends_on 'tbb'     => :optional
  depends_on 'qt'      => :optional
  depends_on :libpng

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway. Will depend on openexr if it's installed.

  def patches
    # Find openCL headers on case sensitive fs: https://github.com/Homebrew/homebrew-science/pull/200
    'https://github.com/Itseez/opencv/commit/6e119049ce3228ca82acb7f4aaa2f4bceeddcbdf.patch'
  end

  def install
    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DWITH_CUDA=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_PNG=OFF
      -DBUILD_JPEG=OFF
      -DBUILD_JASPER=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_PERF_TESTS=OFF
      -DPYTHON_INCLUDE_DIR='#{python.incdir}'
      -DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'
      -DPYTHON_EXECUTABLE='#{python.binary}'
    ]

    if build.build_32_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
      args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'"
      args << "-DOPENCV_EXTRA_CXX_FLAGS='-arch i386 -m32'"
    end
    args << '-DWITH_QT=ON' if build.with? 'qt'
    args << '-DWITH_TBB=ON' if build.with? 'tbb'
    # OpenCL 1.1 is required, but Snow Leopard and older come with 1.0

    # Build with OpenCL support by default.
    if build.without? 'opencl' or MacOS.version < :lion
      args << '-DWITH_OPENCL=OFF'
    else
      args << '-DWITH_OPENCL=ON'
    end

    args << '..'
    mkdir 'macbuild' do
      system 'cmake', *args
      system "make"
      system "make install"
    end
  end


  def caveats
    python.standard_caveats if python
  end
end
