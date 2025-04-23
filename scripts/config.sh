# SPECIFY KITCHEN HOME #
KHOME=$(pwd)

# EXPORT WORKSPACE #
WKSPCE="$KHOME/WORKSPACE"

# SPECIFY CONFIG FILE #
CFG="$KHOME/config.json"
CFG_PRJ="$PRJPTH/config.json"


# GRAB PROJECT NAME FROM CONFIG # LATER #
PRJ=$(jq -r '.project_name' "$CFG" 2>/dev/null)

# GRAB MODELNUMBER FROM CONFIG # LATER #
MDLNR=$(jq -r '.model_number' "$CFG" 2>/dev/null)

# GRAB CSC FROM CONFIG # LATER #
CSC=$(jq -r '.csc' "$CFG" 2>/dev/null)

# GRAB IMEI FROM CONFIG # LATER #
IMEI=$(jq -r '.imei' "$CFG" 2>/dev/null)

# DOWNLOAD FOLDER #
DWNLD="$WKSPCE/download"

# TARGET DOWNLOAD PATH #
TARGETDL="$DWNLD/${mdlnr}_${csc}"

# PROJECT FOLDER #

PRJCT="$WKSPCE/projects"

# FOLDER OF PROJECT #

PRJPTH="$WKSPCE/projects/$prj"

# SCRIPT PATH #
KSCRIPTS="$KHOME/scripts"

CONFIG="$KSCRIPTS/config.sh"

## DEBUG ##
echo $KHOME
#cat $CFG

# ?? UNUSED ?? #
#export MDDL= "$PRJPTH/download"