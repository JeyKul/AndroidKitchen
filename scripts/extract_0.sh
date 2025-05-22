echo $TARGETDL

zip_name="$(ls "$TARGETDL" | grep '\.zip' | head -n 1)"
zip_file="$(realpath "$TARGETDL/$zip_name")"

echo $zip_file

echo "Unzipping $zip_file..." | tee -a "$LOG_FILE"
    if ! unzip -q "$zip_file" -d "$EXTR"; then
        echo "Failed to unzip $zip_file. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
        exit 1
    fi
