#!/bin/bash
# Determine target version and download URL
if [ "$NZBGET_REL" == "stable" ]; then
  LAT_TAG="$(wget -qO- "https://api.github.com/repos/nzbgetcom/nzbget/releases/latest" 2>/dev/null | grep -o '"tag_name": "[^"]*"' | cut -d '"' -f4)"
  if [ -z "$LAT_TAG" ]; then
    echo "---Failed to get stable version from GitHub---"
  fi
  LAT_V_CLEAN="${LAT_TAG#v}"
  DOWNLOAD_URL="https://github.com/nzbgetcom/nzbget/releases/download/${LAT_TAG}/nzbget-${LAT_V_CLEAN}-bin-linux.run"
elif [ "$NZBGET_REL" == "testing" ]; then
  LAT_TAG="testing"
  # Get actual testing release asset URL (version includes date)
  DOWNLOAD_URL="$(wget -qO- "https://api.github.com/repos/nzbgetcom/nzbget/releases/tags/testing" 2>/dev/null | grep -o '"browser_download_url": "[^"]*bin-linux\.run"' | head -1 | cut -d '"' -f4)"
  # Extract version from URL
  LAT_V_CLEAN="$(echo "$DOWNLOAD_URL" | sed -E 's/.*nzbget-(v?[^-]+)-.*/\1/')"
  if [ -z "$DOWNLOAD_URL" ]; then
    echo "---Failed to get testing version from GitHub---"
  fi
else
  echo "---Version manually set to: v$NZBGET_REL---"
  LAT_TAG="$NZBGET_REL"
  LAT_V_CLEAN="${LAT_TAG#v}"
  DOWNLOAD_URL="https://github.com/nzbgetcom/nzbget/releases/download/${LAT_TAG}/nzbget-${LAT_V_CLEAN}-bin-linux.run"
fi

# Check currently installed version
if [ -f ${DATA_DIR}/nzbget/nzbget ]; then
  CUR_V="$( ${DATA_DIR}/nzbget/nzbget -V 2>&1 | head -n1 | awk '{print $2}' )"
  CUR_V_CLEAN="${CUR_V#v}"
else
  CUR_V=""
  CUR_V_CLEAN=""
fi

if [ -z "$DOWNLOAD_URL" ]; then
  if [ -z "$CUR_V" ]; then
    echo "---Can't determine NZBget version, putting container into sleep mode!---"
    sleep infinity
  else
    echo "---Can't determine latest NZBget version, falling back to installed v$CUR_V---"
  fi
fi

# Remove old or failed downloads
rm -rf ${DATA_DIR}/nzbget-*
rm -rf ${DATA_DIR}/*.run

echo "---Version Check---"
echo "Latest: ${LAT_TAG} (${LAT_V_CLEAN}), Installed: ${CUR_V:-none}"

if [ -z "$CUR_V" ]; then
  echo "---NZBget not found, downloading and installing ${LAT_TAG}...---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run "$DOWNLOAD_URL" ; then
    echo "---Successfully downloaded NZBget ${LAT_TAG}---"
  else
    echo "---Something went wrong, can't download NZBget ${LAT_TAG}, putting container into sleep mode!---"
    sleep infinity
  fi
elif [ "$CUR_V_CLEAN" != "$LAT_V_CLEAN" ]; then
  echo "---Version mismatch, installed v$CUR_V, downloading latest ${LAT_TAG}...---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run "$DOWNLOAD_URL" ; then
    echo "---Successfully downloaded NZBget ${LAT_TAG}---"
  else
    echo "---Something went wrong, can't download NZBget ${LAT_TAG}, putting container into sleep mode!---"
    sleep infinity
  fi
elif [ "$CUR_V_CLEAN" == "$LAT_V_CLEAN" ]; then
  echo "---NZBget v$CUR_V up-to-date---"
fi

# Install from .run file if present
if [ -f ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run ]; then
  echo "---Installing NZBget from installer...---"
  chmod +x ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run
  cd ${DATA_DIR}
  # Extract using the installer with target directory
  ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run --target ${DATA_DIR}/nzbget --force > /dev/null 2>&1
  if [ ! -f ${DATA_DIR}/nzbget/nzbget ]; then
    # Fallback: extract to default location and move
    echo "---Trying default extraction...---"
    ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run > /dev/null 2>&1
    for dir in ${DATA_DIR}/nzbget-*; do
      if [ -f "$dir/nzbget" ]; then
        rm -rf ${DATA_DIR}/nzbget
        mv "$dir" ${DATA_DIR}/nzbget
        break
      fi
    done
  fi
  rm -f ${DATA_DIR}/nzbget-${LAT_V_CLEAN}.run
  echo "---NZBget installed---"
fi

echo "---Preparing Server---"
if [ ! -f ${DATA_DIR}/nzbget.conf ]; then
  cp ${DATA_DIR}/nzbget/nzbget.conf ${DATA_DIR}/nzbget.conf
fi

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting NZBget---"
cd ${DATA_DIR}
if [ ! -f "${DATA_DIR}/nzbget/nzbget" ]; then
  echo "Something went wrong, couldn't find server executable."
  echo "Putting container into sleep mode!"
  sleep infinity
else
  exec ${DATA_DIR}/nzbget/nzbget --server --configfile ${DATA_DIR}/nzbget.conf -o OutputMode=log -o ControlUsername=${NZBGET_USERNAME} -o ControlPassword= ${START_PARAMS}
fi