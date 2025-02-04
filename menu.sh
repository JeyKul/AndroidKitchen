#!/usr/bin/env bash


export KHOME=$(pwd)
# Function to display the main menu
show_menu() {
    clear
    echo "===================================="
    echo "        Android Kitchen Menu        "
    echo "===================================="
    echo "1. Create New Project"
    echo "2. Select Existing Project"
    echo "9. Exit"
    echo "===================================="
}

# Function to create a new project
create_new_project() {
    echo "Creating a new project..."
    read -p "Enter project name: " project_name
    config_file="$prj/config.json"
    
    if [[ -d "$prj" ]]; then
        echo "Project '$project_name' already exists. Please choose a different name."
        return
    fi
    
    mkdir -p "$prj" "$EXTRACT_DIR" "$WORKDIR_DIR" "$INPUT_DIR" "$MDDL"
    echo "Project directory created: $prj"
    
    echo "Select device brand:"
    echo "1. Samsung"
    echo "2. Other"
    read -p "Enter choice (1 or 2): " brand_choice
    
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
        
        cat > "$config_file" <<EOF
{
    "project_name": "$project_name",
    "model_number": "$model_number",
    "csc": "$csc",
    "imei": "$imei",
    "firmware_count": "$firmware_count"
}
EOF
        source $KSCRIPTS/config.sh
        echo "Project configuration saved!"
        echo "Downloading firmware..."
        for ((i=1; i<=firmware_count; i++)); do
            firmware_dir="$prj/firmware_$i"
            mkdir -p "$firmware_dir"
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

# Function to list and select a project
select_project() {
    echo "Available projects:"
    select project in $(ls "$PROJECTS_DIR"); do
        if [[ -n "$project" ]]; then
            cp $KHOME/$PROJECTS_DIR/$project/config.json $KHOME/config.json
            source $KHOME/scripts/config.sh
            project_menu "$KHOME/config.json"
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
}

# Function to show the project menu
project_menu() {
    config_file="$1"

    
    while true; do
        echo "===================================="
        echo "  Project: $mdlnr"
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
                echo $MDDL
                echo $PRJPTH
                echo $SOURCE_FOLDER
                echo $DEST_FOLDER
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

trap 'rm -f $KHOME/config.json' EXIT

# Main script logic
main() {
    while true; do
        
        show_menu
        source $KHOME/scripts/prepare.sh
        echo $PROJECTS_DIR
        echo $DOWNLOADS_DIR
        echo $INPUT_DIR
        echo $WORKDIR_DIR
        echo $LOG_DIR
        echo $KHOME
        echo $KSCRIPTS
        echo $LOG_FILE
        read -p "Enter your choice: " choice
        
        case "$choice" in
            1)
                create_new_project
                ;;
            2)
                select_project
                ;;
            9)
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
        read -p "Press Enter to continue..."
    done
}

main