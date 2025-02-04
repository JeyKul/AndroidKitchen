config_file=$KHOME/config.json

cat $config_file

export prj=$(jq -r '.project_name' "$config_file")
export mdlnr=$(jq -r '.model_number' "$config_file")
export csc=$(jq -r '.csc' "$config_file")
export imei=$(jq -r '.imei' "$config_file")
export target_dir="$ODIN_DIR/${mdlnr}_${csc}"
export ODIN_DIR="$KITCHEN_HOME/projects/$prj/downloads"