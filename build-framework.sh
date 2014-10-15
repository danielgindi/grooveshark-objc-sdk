# Find the folder containing this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup for the build
BUILD_DIR="${DIR}/build-temp"
PRODUCTS_DIR="${BUILD_DIR}/Build/Products"
OUTPUT_DIR="${DIR}/dist"
PROJECT_PATH="${DIR}/GroovesharkSDK/GroovesharkSDK.xcodeproj"
TARGET_NAME=GroovesharkSDK
FRAMEWORK_NAME=GroovesharkSDK

# Build for Simulator/Debug

xcodebuild -project "${PROJECT_PATH}" -scheme "${TARGET_NAME}" -configuration Debug -derivedDataPath "${BUILD_DIR}" -arch x86_64 -arch i386 -sdk iphonesimulator clean build

# Build for Device/Release

xcodebuild -project "${PROJECT_PATH}" -scheme "${TARGET_NAME}" -configuration Release -derivedDataPath "${BUILD_DIR}" -arch arm64 -arch armv7 -arch armv7s -sdk iphoneos clean build

# Delete temporary folder if exists

if [ -d "${PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework" ]
then
rm -dR "${PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework"
fi

# Copy structure of framework folder from one of the configurations, without the binary itself

cp -R "${PRODUCTS_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework" "${PRODUCTS_DIR}/"
unlink "${PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework/${TARGET_NAME}"

# Create a binary that is the combination of both Simulator and Device, containing all possible architectures

lipo -create -output "${PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework/${TARGET_NAME}" "${PRODUCTS_DIR}/Debug-iphonesimulator/${FRAMEWORK_NAME}.framework/${TARGET_NAME}" "${PRODUCTS_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework/${TARGET_NAME}"

# Create the output folder if not exists

if [ ! -d "${OUTPUT_DIR}" ]
then
mkdir "${OUTPUT_DIR}"
fi

# And delete the old framework if there's one

if [ -d "${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework" ]
then
rm -dR "${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework"
fi

# Move the finished framework to the output folder

mv "${PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework" "${OUTPUT_DIR}/"

# Delete the temporary build folder

if [ -d "${BUILD_DIR}" ]
then
rm -dR "${BUILD_DIR}"
fi
