#!/usr/bin/env bash

# PATHS #
source ./scripts/config.sh
source $KSCRIPTS/prepare.sh
## DEBUG ##
echo $KHOME $WKSPCE $CFG $PRJ $MDLNR $CSC $IMEI $DWNLD $TARGETDL $PRJCT $PRJPTH $KSCRIPTS

# VENV ATTEMPT # 

if ! source venv/bin/activate > /dev/null 2>&1; then
    echo "Virtual environment not found or activation failed. Running script.sh..."
    # ADD SCRIPT #
fi

# MENU #
show_menu() {
    clear
    echo "===================================="
    echo "        Android Kitchen Menu        "
    echo "===================================="
    echo "1. Create New Project"
    echo "2. Select Existing Project"
    echo "7. Clean AndroidKitchen"
    echo "8. Check Dependencies"
    echo "9. Exit"
    echo "echo $KHOME"
    echo "===================================="
}

trap 'rm -f $KHOME/config.json' EXIT

# MAIN SCRIPT LOGIC #
main() {
    while true; do
        
        show_menu
        source $KHOME/scripts/prepare.sh

        read -p "Enter your choice: " choice
        
        case "$choice" in
            1)
                source $KSCRIPTS/create_new_project.sh
                create_new_project
                ;;
            2)
                source $KSCRIPTS/create_new_project.sh 
                select_project
                ;;
            7)
                source $KSCRIPTS/clean.sh
                ;;
            8)
                source scripts/check_dependencies.sh
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

