#!/usr/bin/env bash

# This script requires Xcode 13.0+ to be installed and selected
# as the DEVELOPER_DIR.

# It is expected you will run this script from the root of the package

SCHEME="Vexil-Package"
DERIVED_DATA=".build/DerivedData"

PRODUCT_DIR="${DERIVED_DATA}/Build/Products/Debug"
VEXIL_DOCCARCHIVE="${PRODUCT_DIR}/Vexil.doccarchive"
VEXILLOGRAPHER_DOCCARCHIVE="${PRODUCT_DIR}/Vexillographer.doccarchive"

WEBSITE_DIR=".github/website"

WORKING="docs"

# Build our docs
xcodebuild docbuild \
    -scheme "${SCHEME}" \
    -derivedDataPath "${DERIVED_DATA}" \
    -destination "platform=macOS,name=Any Mac"

# Make sure they exist
if [ ! -d "${VEXIL_DOCCARCHIVE}" ]; then
    >&2 echo "Could not find Vexil.doccarchive inside ${PRODUCT_DIR}"
    exit 1
fi

if [ ! -d "${VEXILLOGRAPHER_DOCCARCHIVE}" ]; then
    >&2 echo "Could not find Vexillographer.doccarchive inside ${PRODUCT_DIR}"
    exit 1
fi

# Lets start assembling
rm -rf "${WORKING}"
mkdir -p "${WORKING}"

# We copy the entire archive from Vexil into our working dir
cp -R "${VEXIL_DOCCARCHIVE}"/* "${WORKING}"

# But only the docs from Vexillographer
cp -R "${VEXILLOGRAPHER_DOCCARCHIVE}"/data/documentation/* "${WORKING}/data/documentation/"
cp -R "${VEXILLOGRAPHER_DOCCARCHIVE}"/images/* "${WORKING}/images/"

# Re-create the .json structure inside /documentation
find "${WORKING}/data" -type f -name '*.json' \
    | sed 's%data/%%g' \
    | sed 's%\.json%%g' \
    | xargs -n 1 mkdir -p

# Copy the index.html file from the root into each of those folders
find "${WORKING}/documentation" -type d \
    | xargs -n 1 cp "${WORKING}/index.html"

# Copy our website root files over the top too
cp "${WEBSITE_DIR}/index.html" "${WORKING}"
cp "${WEBSITE_DIR}/styles.css" "${WORKING}/css"
cp "${WEBSITE_DIR}/vexil.svg" "${WORKING}/img"
