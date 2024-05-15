# tinySlideMovieMaker

```
ruby slideMovieMaker.rb -s ~/Desktop/movie/ -v ~/Desktop/voice/ -o ~/tmp/output
```


# Trouble shoot

## confirmed environment

```
ffmpeg -version
ffmpeg version 6.0 Copyright (c) 2000-2023 the FFmpeg developers
built with Apple clang version 14.0.0 (clang-1400.0.29.202)
configuration: --prefix=/opt/homebrew/Cellar/ffmpeg/6.0_2 --enable-shared --enable-pthreads --enable-version3 --cc=clang --host-cflags= --host-ldflags= --enable-ffplay --enable-gnutls --enable-gpl --enable-libaom --enable-libaribb24 --enable-libbluray --enable-libdav1d --enable-libjxl --enable-libmp3lame --enable-libopus --enable-librav1e --enable-librist --enable-librubberband --enable-libsnappy --enable-libsrt --enable-libsvtav1 --enable-libtesseract --enable-libtheora --enable-libvidstab --enable-libvmaf --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxml2 --enable-libxvid --enable-lzma --enable-libfontconfig --enable-libfreetype --enable-frei0r --enable-libass --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopenjpeg --enable-libspeex --enable-libsoxr --enable-libzmq --enable-libzimg --disable-libjack --disable-indev=jack --enable-videotoolbox --enable-audiotoolbox --enable-neon
libavutil      58.  2.100 / 58.  2.100
libavcodec     60.  3.100 / 60.  3.100
libavformat    60.  3.100 / 60.  3.100
libavdevice    60.  1.100 / 60.  1.100
libavfilter     9.  3.100 /  9.  3.100
libswscale      7.  1.100 /  7.  1.100
libswresample   4. 10.100 /  4. 10.100
libpostproc    57.  1.100 / 57.  1.100
```

## Downgrade Any (6.1, etc.) to 6.0.2

If you install ffmpeg 6.1, there is issue on the encoded result on the -i still image case,
then you need to re-install ffmpeg 6.0.2.

1. open ```https://github.com/Homebrew/homebrew-core/blob/042325cd385225e055e2ccf676abe0072cd38dcb/Formula/f/ffmpeg.rb```
and download the raw file or execute following

```
open https://raw.githubusercontent.com/Homebrew/homebrew-core/042325cd385225e055e2ccf676abe0072cd38dcb/Formula/f/ffmpeg.rb
```

2. ```brew uninstall --ignore-dependencies ffmpeg``` ```brew unlink ffmpeg```
3. ```brew install ffmpeg.rb```

You may need to reinstall ffmpeg@6 (but the 6.1- have issue. should use 6.0.x)

```
brew reinstall ffmpeg@6
brew install ffmpeg.rb
```

4. Fix the dependencies
```
cd /opt/homebrew/opt/libvmaf/lib
ln -s libvmaf.3.dylib libvmaf.1.dylib

cd /opt/homebrew/opt/jpeg-xl/lib
ln -s libjxl.0.9.dylib libjxl.0.8.dylib
ln -s libjxl.0.10.2.dylib libjxl.0.8.dylib (after 7.1 is installed)

cd /opt/homebrew/opt/jpeg-xl/lib
ln -s libjxl_threads.0.9.dylib libjxl_threads.0.8.dylib
ln -s libjxl_threads.0.10.2.dylib libjxl_threads.0.8.dylib (after 7.1 is installed)

cd /opt/homebrew/opt/rav1e/lib
ln -s librav1e.0.7.dylib librav1e.0.6.dylib

cd /opt/homebrew/Cellar/x265/3.5/lib
cp libx265.199.dylib ../../3.6/lib/

cd /opt/homebrew/opt/svt-av1/lib
ln -s libSvtAv1Enc.2.0.0.dylib libSvtAv1Enc.1.dylib 
```

5. Check the version
```
ffmpeg -version
ffmpeg version 6.0 Copyright (c) 2000-2023 the FFmpeg developers
built with Apple clang version 14.0.0 (clang-1400.0.29.202)
configuration: --prefix=/opt/homebrew/Cellar/ffmpeg/6.0_2 --enable-shared --enable-pthreads --enable-version3 --cc=clang --host-cflags= --host-ldflags= --enable-ffplay --enable-gnutls --enable-gpl --enable-libaom --enable-libaribb24 --enable-libbluray --enable-libdav1d --enable-libjxl --enable-libmp3lame --enable-libopus --enable-librav1e --enable-librist --enable-librubberband --enable-libsnappy --enable-libsrt --enable-libsvtav1 --enable-libtesseract --enable-libtheora --enable-libvidstab --enable-libvmaf --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxml2 --enable-libxvid --enable-lzma --enable-libfontconfig --enable-libfreetype --enable-frei0r --enable-libass --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopenjpeg --enable-libspeex --enable-libsoxr --enable-libzmq --enable-libzimg --disable-libjack --disable-indev=jack --enable-videotoolbox --enable-audiotoolbox --enable-neon
libavutil      58.  2.100 / 58.  2.100
libavcodec     60.  3.100 / 60.  3.100
libavformat    60.  3.100 / 60.  3.100
libavdevice    60.  1.100 / 60.  1.100
libavfilter     9.  3.100 /  9.  3.100
libswscale      7.  1.100 /  7.  1.100
libswresample   4. 10.100 /  4. 10.100
libpostproc    57.  1.100 / 57.  1.100
```
