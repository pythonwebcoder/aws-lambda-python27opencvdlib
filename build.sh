#!/bin/bash

# Setting up build env
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc python-devel chrpath
mkdir -p lambda-package/cv2 lambda-package/dlib build/numpy build/dlib

# download and make patchelf - this will let us quickly update dlib.so's LD_LIBRARY path
mkdir -p build/patchelf
(
cd build/patchelf
wget https://nixos.org/releases/patchelf/patchelf-0.9/patchelf-0.9.tar.bz2 #https://github.com/NixOS/patchelf/archive/0.9.zip
tar xvfj patchelf-0.9.tar.bz2
cd patchelf-0.9 && ./configure && make && sudo make install
)

# Build numpy
sudo yum -y install blas
sudo yum -y install lapack
sudo yum -y install atlas-sse3-devel
pip install -U --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib64/python2.7/site-packages/numpy lambda-package
mkdir lambda-package/lib
cp /usr/lib64/atlas-sse3/liblapack.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libptf77blas.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libf77blas.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libptcblas.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libcblas.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libatlas.so.3 lambda-package/lib/.
cp /usr/lib64/atlas-sse3/libptf77blas.so.3 lambda-package/lib/.
cp /usr/lib64/libgfortran.so.3 lambda-package/lib/.
cp /usr/lib64/libquadmath.so.0 lambda-package/lib/.
#find "lambda-package/numpy/" -name "**.so" | xargs strip

# Build OpenCV 3.2
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/Itseez/opencv.git
	cd opencv
	git checkout 3.2.0
	cmake										\
		-D CMAKE_BUILD_TYPE=RELEASE				\
		-D WITH_TBB=ON							\
		-D WITH_IPP=ON							\
		-D WITH_V4L=ON							\
		-D ENABLE_AVX=ON						\
		-D ENABLE_SSSE3=ON						\
		-D ENABLE_SSE41=ON						\
		-D ENABLE_SSE42=ON						\
		-D ENABLE_POPCNT=ON						\
		-D ENABLE_FAST_MATH=ON					\
		-D BUILD_EXAMPLES=OFF					\
		-D BUILD_TESTS=OFF						\
		-D BUILD_PERF_TESTS=OFF					\
		-D PYTHON2_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		.
	make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
cp build/opencv/lib/cv2.so lambda-package/cv2/__init__.so
cp -L build/opencv/lib/*.so.3.2 lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/__init__.so
touch lambda-package/cv2/__init__.py

# build dlib and add an init module file for python
sudo yum install -y blas-devel boost-devel lapack-devel
(
	cd build
	git clone https://github.com/davisking/dlib.git
	cd dlib/python_examples/
	mkdir build
	cd build
	cmake -D USE_SSE4_INSTRUCTIONS:BOOL=ON ../../tools/python
	cmake --build . --config Release --target install
)
cp build/dlib/python_examples/dlib.so lambda-package/dlib/__init__.so
cp /usr/lib64/libboost_python-mt.so.1.53.0 lambda-package/dlib/
touch lambda-package/dlib/__init__.py
patchelf --set-rpath '$ORIGIN' lambda-package/dlib/__init__.so

# This shape_predictor for dlib is useful for face recognition
wget http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
bzip2 -d shape_predictor_68_face_landmarks.dat.bz2
mv shape_predictor_68_face_landmarks.dat lambda-package/shape_predictor_68_face_landmarks.dat

# Copy python function and zip
cp lambda_function.py lambda-package/lambda_function.py
cd lambda-package
zip -r ../lambda-package.zip *
