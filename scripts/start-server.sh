#!/bin/bash
if [ "$NZBGET_V" == "latest" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/nzbget| grep LATEST | cut -d '=' -f2)"
elif [ "$NZBGET_V" == "prerelease" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/nzbget | grep PRERELEASE | cut -d '=' -f2)"
else
    echo "---Version manually set to: v$NZBGET_V---"
    LAT_V="$NZBGET_V"
fi

if [ ! -f ${DATA_DIR}/nzbget/nzbget ]; then
    CUR_V=""
else
    cd ${DATA_DIR}
    CUR_V="$(${DATA_DIR}/nzbget/nzbget --version | cut -d ':' -f2 | cut -d ' ' -f2 | sed -e 's/-testing//g')"
fi

if [ -z $LAT_V ]; then
    if [ -z $CUR_V ]; then
        echo "---Can't get latest version of nzbget, putting container into sleep mode!---"
        sleep infinity
    else
        echo "---Can't get latest version of nzbget, falling back to v$CUR_V---"
    fi
fi

if [ -f ${DATA_DIR}/nzbget-v$LAT_V.run ]; then
    rm -rf ${DATA_DIR}/nzbget-v$LAT_V.run
fi

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
    echo "---nzbget not found, downloading and installing v$LAT_V...---"
    cd ${DATA_DIR}
    if [ "$NZBGET_V" == "prerelease" ]; then
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-v$LAT_V.run "https://github.com/nzbget/nzbget/releases/download/v${LAT_V}/nzbget-${LAT_V%-*}-testing-${LAT_V##*-}-bin-linux.run" ; then
            echo "---Successfully downloaded nzbget v$LAT_V---"
        else
            echo "---Something went wrong, can't download nzbget v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
    else
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-v$LAT_V.run "https://github.com/nzbget/nzbget/releases/download/v${LAT_V}/nzbget-${LAT_V}-bin-linux.run" ; then
            echo "---Successfully downloaded nzbget v$LAT_V---"
        else
            echo "---Something went wrong, can't download nzbget v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
    fi
    mkdir ${DATA_DIR}/nzbget
    chmod +x ${DATA_DIR}/nzbget-v$LAT_V.run
    ${DATA_DIR}/nzbget-v$LAT_V.run --destdir ${DATA_DIR}/nzbget >/dev/null
    rm ${DATA_DIR}/nzbget-v$LAT_V.run
elif [ "$CUR_V" != "$LAT_V" ]; then
    echo "---Version missmatch, installed v$CUR_V, downloading and installing v$LAT_V...---"
    cd ${DATA_DIR}
    if [ "$NZBGET_V" == "prerelease" ]; then
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-v$LAT_V.run "https://github.com/nzbget/nzbget/releases/download/v${LAT_V}/nzbget-${LAT_V%-*}-testing-${LAT_V##*-}-bin-linux.run" ; then
            echo "---Successfully downloaded nzbget v$LAT_V---"
        else
            echo "---Something went wrong, can't download nzbget v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
    else
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/nzbget-v$LAT_V.run "https://github.com/nzbget/nzbget/releases/download/v${LAT_V}/nzbget-${LAT_V}-bin-linux.run" ; then
            echo "---Successfully downloaded nzbget v$LAT_V---"
        else
            echo "---Something went wrong, can't download nzbget v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
    fi
    rm -rf ${DATA_DIR}/nzbget
    mkdir ${DATA_DIR}/nzbget
    chmod +x ${DATA_DIR}/nzbget-v$LAT_V.run
    ${DATA_DIR}/nzbget-v$LAT_V.run --destdir ${DATA_DIR}/nzbget >/dev/null
    rm ${DATA_DIR}/nzbget-v$LAT_V.run
elif [ "$CUR_V" == "$LAT_V" ]; then
    echo "---nzbget v$CUR_V up-to-date---"
fi

echo "---Preparing Server---"
if [ ! -f ${DATA_DIR}/nzbget.conf ]; then
    cp ${DATA_DIR}/nzbget/nzbget.conf ${DATA_DIR}/nzbget.conf
    sleep 2
    sed -i '/ControlUsername=/c\ControlUsername=' ${DATA_DIR}/nzbget.conf
    sed -i '/ControlPassword=/c\ControlPassword=' ${DATA_DIR}/nzbget.conf
    sed -i '/MainDir=/c\MainDir=/mnt/downloads' ${DATA_DIR}/nzbget.conf
    sed -i '/DestDir=${MainDir}/c\DestDir=${MainDir}' ${DATA_DIR}/nzbget.conf
    sed -i '/LockFile=${MainDir}/c\LockFile=${AppDir}\/nzbget.lock' ${DATA_DIR}/nzbget.conf
    sed -i '/LogFile=${MainDir}/c\LogFile=/nzbget\/nzbget.log' ${DATA_DIR}/nzbget.conf
    sed -i '/ScriptDir=${AppDir}/c\ScriptDir=/nzbget\/scripts' ${DATA_DIR}/nzbget.conf
fi
if [ ! -d ${DATA_DIR}/scripts ]; then
    mkdir ${DATA_DIR}/scripts
fi
if [ -f ${DATA_DIR}/nzbget/nzbget.lock ]; then
    rm -rf ${DATA_DIR}/nzbget/nzbget.lock
fi
if [ "${DELETE_LOG_ON_START}" == "true" ]; then
    if [ -f ${DATA_DIR}/nzbget.log ]; then
        rm -rf ${DATA_DIR}/nzbget.log
    fi
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "+-------------------------------------------------------------"
echo "|"
echo "| This container for ARM is deprecated and is no"
echo "| longer actively maintained or further developed!"
echo "|"
echo "|  Container will start in 60 seconds!"
echo "|"
echo "+-------------------------------------------------------------"
sleep 60

echo "---Starting nzbget---"
cd ${DATA_DIR}
${DATA_DIR}/nzbget/nzbget --server --configfile ${DATA_DIR}/nzbget.conf --option OutputMode=Log ${START_PARAMS}