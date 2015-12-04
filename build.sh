#!/bin/bash

pwd=`pwd`
LIPO=$(xcrun -sdk iphoneos -find lipo)
export IPHONEOS_DEPLOYMENT_TARGET="8.0"

buildPlatform="all"
usingBitcode="YES"
cleanOutput="NO"

findLatestSDKVersion()
{
  SDKVERSION=`xcrun --sdk iphoneos --show-sdk-version`
}

xcodeBuild()
{
  if [[ $SDKVERSION < 9.0  ]]; then
    usingBitcode == "NO"
  fi

  if [[ $1 == "iphoneos" ]]; then
    archs='armv7 armv7s arm64'
  else
    archs='i386 x86_64'
  fi

  if [[ $usingBitcode == "YES" ]]; then
    xcodebuild -project lua.xcodeproj ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" CONFIGURATION_BUILD_DIR="$pwd/output/$1" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" OTHER_CFLAGS="-fembed-bitcode -DLUA_USE_MACOSX" -sdk "$1$SDKVERSION" -scheme lua clean build
  else
    xcodebuild -project lua.xcodeproj ONLY_ACTIVE_ARCH=NO VALID_ARCHS="$archs" CONFIGURATION_BUILD_DIR="$pwd/output/$1" -configuration Release ENABLE_BITCODE="$usingBitcode" ARCHS="$archs" OTHER_CFLAGS="-DLUA_USE_MACOSX" -sdk "$1$SDKVERSION" -scheme lua clean build
  fi
}

buildForAllPlatform()
{
  xcodeBuild iphoneos
  xcodeBuild iphonesimulator

  mkdir -p $pwd/output/Universal/lib
  LIPO -create $pwd/output/iphoneos/liblua.a $pwd/output/iphonesimulator/liblua.a -output $pwd/output/Universal/lib/liblua.a

  mkdir -p $pwd/output/Universal/include
  cp $pwd/lua/lua.h $pwd/lua/luaconf.h $pwd/lua/lualib.h $pwd/lua/lauxlib.h $pwd/lua/lua.hpp $pwd/output/Universal/include
}

findLatestSDKVersion

for i in "$@"
do
  case $i in
    -p=*|--platform=*)
    buildPlatform="${i#*=}"
    shift
    ;;
    -b=*|--bitcode=*)
    usingBitcode="${i#*=}"
    shift
    ;;
    -c|--clean)
    cleanOutput="YES"
    shift
    ;;
    *)

    ;;
  esac
done

if [[ $cleanOutput == "NO" ]]; then
  if [[ usingBitcode -ne "YES" && usingBitcode -ne "NO" ]]; then
    usingBitcode="YES"
  fi

  echo "Using bitcode: $usingBitcode"
  echo "Platform: $buildPlatform"

  if [[ $buildPlatform == "all" ]]; then
    buildForAllPlatform
  elif [[ $buildPlatform == "device" ]]; then
    xcodeBuild iphoneos
  elif [[ $buildPlatform == "simulator" ]]; then
    xcodeBuild iphonesimulator
  else
    buildForAllPlatform
  fi
else
  `rm -rf $pwd/output`
  echo "Output folder cleaned!"
fi
