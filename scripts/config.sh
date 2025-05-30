# SPECIFY KITCHEN HOME #
KHOME=$(pwd)

# EXPORT WORKSPACE #
WKSPCE="$KHOME/WORKSPACE"

# SPECIFY CONFIG FILE #
CFG="$KHOME/config.json"
CFG_PRJ="$PRJPTH/config.json"

# LOG SETUP #
LOG=$WKSPCE/logs
LOG_FILE="$LOG/log.txt"

# GRAB PROJECT NAME FROM CONFIG # LATER #
prj=$(jq -r '.project_name' "$CFG")

# GRAB MODELNUMBER FROM CONFIG # LATER #
MDLNR=$(jq -r '.model_number' "$CFG")

# GRAB CSC FROM CONFIG # LATER #
CSC=$(jq -r '.csc' "$CFG")

# GRAB IMEI FROM CONFIG # LATER #
IMEI=$(jq -r '.imei' "$CFG")

# DOWNLOAD FOLDER #
DWNLD="$WKSPCE/download"

# TARGET DOWNLOAD PATH #
TARGETDL="$DWNLD/${MDLNR}_${CSC}"

# EXTRACT STEP ONE # TAR.MD5 ARCHIVES #
EXTR="$WKSPCE/extract"
AP="$EXTR/ap"
CP="$EXTR/cp"
CSC2="$EXTR/csc"
BL="$EXTR/bl"

# PROJECT FOLDER #

PRJCT="$WKSPCE/projects"

# FOLDER OF PROJECT AND ITS FOLDERS #

PRJPTH="$WKSPCE/projects/$prj"

EXTRPRJ="$PRJPTH/.extracted"
PARTPRJ="$PRJPTH/partitions"

# SCRIPT PATH #
KSCRIPTS="$KHOME/scripts"

CONFIG="$KSCRIPTS/config.sh"

SLDR="$KSCRIPTS/samloadersetup.sh"

## DEBUG ##
echo $KHOME
#cat $CFG

# ?? UNUSED ?? #
#export MDDL= "$PRJPTH/download"