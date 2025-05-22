#!/usr/bin/env bash


create_new_project() {
    # STEP 1 #
    # MESSAGE #
    echo "Creating a new project..."

    # PROMPT TO ENTER NAME #
    read -p "Enter project name: " prj

    # ERROR HANDLER IF PROJECT EXISTS ALREADY #
    if [[ -d "$KHOME/$prj" ]]; then
        echo "Project '$prj' already exists. Please choose a different name."
        return
    fi
    
    # RE-RUN OF CONFIG SCRIPT #
    source $CONFIG

    # SERIES OF NEW FOLDERS
    mkdir -p "$PRJPTH"
    echo "I am about to create: $PRJPTH"
    mkdir -p "$DWNLD"
    mkdir -p "$MDDL"
    echo "Project directory created: $prj"
    
    # STEP 2 #
    echo "Select device brand:"
    echo "1. Samsung"
    echo "2. Other"

    # PROMPT TO CHOOSE BRAND #
    read -p "Enter choice (1 or 2): " brand_choice
    
    # STUFF FOR DOWNLOADER #
    if [[ "$brand_choice" == "1" ]]; then
        read -p "Enter Samsung model number (e.g., SM-S908B (caseinsensitive)): " model_number
        model_number=$(echo "$model_number" | tr '[:lower:]' '[:upper:]')
        read -p "Enter CSC (e.g., XEU): " csc
        csc=$(echo "$csc" | tr '[:lower:]' '[:upper:]')
        read -p "Enter IMEI or serial number: " imei
        read -p "Do you want to download more than one firmware version? (y/n): " download_multiple
        
        if [[ "$download_multiple" == "y" || "$download_multiple" == "Y" ]]; then
            read -p "How many firmware versions do you want to download? " firmware_count
        else
            firmware_count=1
        fi
        source $CONFIG
        cat > "$CFG_PRJ" <<EOF
{
    "project_name": "$prj",
    "model_number": "$model_number",
    "csc": "$csc",
    "imei": "$imei",
    "firmware_count": "$firmware_count"
}
EOF
        source $CONFIG
        echo "Project configuration saved!"
        echo "Downloading firmware..."
        for ((i=1; i<=firmware_count; i++)); do
            mkdir -p $DWNLD/$model_number
            (
                cd "$firmware_dir" || exit
                source $KSCRIPTS/download_fw.sh -f "$mdlnr" "$csc" "$imei"
            ) &
        done
        wait
        echo "Firmware download complete!"
    else
        echo "Other brands not supported yet."
    fi
}

select_project() {
    echo "Available projects:"
    mapfile -t valid_projects < <(find "$PRJCT" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/config.json" \; -print | sed 's:.*/::')

    if [[ ${#valid_projects[@]} -eq 0 ]]; then
        echo "No valid projects found (missing config.json)."
        return
    fi

    select project in "${valid_projects[@]}"; do
        if [[ -n "$project" ]]; then
            PRJPTH="$PRJCT/$project"
            cp "$PRJPTH/config.json" "$KHOME/config.json"
            source "$KHOME/scripts/config.sh"
            project_menu "$KHOME/config.json"
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
}



# EXISTING PROJECT MENU #

project_menu() {
    config_file="$1"

    
    while true; do
        echo "===================================="
        echo "  Project: $MDLNR"
        echo "===================================="
        echo "1. Check for Firmware Update"
        echo "2. Download Firmware"
        echo "3. Extract Downloaded Firmware"
        echo "9. Back to Main Menu"
        echo "===================================="
        read -p "Enter your choice: " choice
        
        case "$choice" in
            1)
                echo "Checking for firmware update..."
                source $KSCRIPTS/download_fw.sh "$mdlnr" "$csc" "$imei"
                ;;
	        2)  echo "Downloading FW"
		        source $KSCRIPTS/download_fw.sh -f "$mdlnr" "$csc" "$imei"
		        ;;
            3)
                echo "Extracting firmware..."
                rm $DEST_FOLDER/*
                bash $KSCRIPTS/extract_fw.sh --source $SOURCE_FOLDER --dest $DEST_FOLDER
                echo "$MDDL^" $Kdebug
                echo "$PRJPTH" $Kdebug
                echo "$SOURCE_FOLDER" $Kdebug
                echo "$DEST_FOLDER" $Kdebug
                ;;
            990)
                clear
                source $CONFIG
                echo "extract_0.sh"
                source $KSCRIPTS/extract_0.sh
                ;;
            991)
                clear
                echo "extract_1.sh"
                source $KSCRIPTS/extract_1.sh
                ;;
            992)
                clear
                echo "extract_2.sh"
                source $KSCRIPTS/extract_2.sh
                ;;
            993)
                clear
                echo "extract_3.sh"
                source $KSCRIPTS/extract_3.sh
                ;;
            9)
                break
                ;;
            *)
                echo "Invalid choice. Try again."
                ;;
        esac
    done
}