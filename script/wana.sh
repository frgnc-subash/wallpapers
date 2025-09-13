#!/bin/bash

# Wallpaper Renamer Script
# This script renames wallpaper files with a consistent naming pattern

# Configuration
PREFIX="wallpaper"                                
START_NUMBER=1                                   
DRY_RUN=false                                    

# Supported image extensions
SUPPORTED_EXTENSIONS=("jpg" "jpeg" "png" "bmp" "gif" "tiff" "webp" "svg")

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --prefix PREFIX    Set filename prefix (default: wallpaper)"
    echo "  -n, --start-number NUM Set starting number (default: 1)"
    echo "  -d, --dry-run          Preview changes without actually renaming"
    echo "  -h, --help             Show this help message"
    echo "  -e, --extensions       List supported file extensions"
}


list_extensions() {
    echo "Supported file extensions: ${SUPPORTED_EXTENSIONS[*]}"
}


ask_for_directory() {
    local folder_path
    if command -v zenity &> /dev/null; then
        folder_path=$(zenity --file-selection --directory --title="Select Wallpapers Folder" 2>/dev/null)
    elif command -v kdialog &> /dev/null; then
        folder_path=$(kdialog --getexistingdirectory . --title "Select Wallpapers Folder" 2>/dev/null)
    elif command -v osascript &> /dev/null; then
        folder_path=$(osascript <<EOF 2>/dev/null
tell application "System Events"
    activate
    set folderPath to POSIX path of (choose folder with prompt "Select Wallpapers Folder")
end tell
EOF
)
    fi
    
   
    if [[ -z "$folder_path" ]]; then
        echo "No graphical dialog tool found. Please enter the path manually." >&2
        while true; do
            read -p "Enter the path to your wallpapers folder: " folder_path
            
  
            folder_path="${folder_path/#\~/$HOME}"
            
            if [[ -z "$folder_path" ]]; then
                echo "Please enter a valid path."
                continue
            fi
            
            if [[ ! -d "$folder_path" ]]; then
                echo "Error: Directory '$folder_path' does not exist!"
                read -p "Would you like to create this directory? (y/N): " create_dir
                if [[ "$create_dir" =~ ^[Yy]$ ]]; then
                    mkdir -p "$folder_path"
                    if [[ $? -eq 0 ]]; then
                        echo "Directory created successfully!"
                        break
                    else
                        echo "Failed to create directory. Please try another path."
                        continue
                    fi
                else
                    continue
                fi
            else
                break
            fi
        done
    fi
   
    if [[ ! -d "$folder_path" ]]; then
        echo "Error: Selected directory '$folder_path' does not exist!"
        exit 1
    fi
    
    echo "$folder_path"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--prefix)
            PREFIX="$2"
            shift 2
            ;;
        -n|--start-number)
            START_NUMBER="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -e|--extensions)
            list_extensions
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            echo "This script doesn't take positional arguments. Use options instead."
            usage
            exit 1
            ;;
    esac
done


echo "=== Wallpaper Renamer ==="
WALLPAPER_DIR=$(ask_for_directory)

echo "Selected folder: $WALLPAPER_DIR"


declare -a lower_extensions
for ext in "${SUPPORTED_EXTENSIONS[@]}"; do
    lower_extensions+=("${ext,,}")
done


is_supported_extension() {
    local filename="$1"
    local extension="${filename##*.}"
    extension="${extension,,}" 
    
    for ext in "${lower_extensions[@]}"; do
        if [[ "$extension" == "$ext" ]]; then
            return 0
        fi
    done
    return 1
}


sanitize_filename() {
    echo "$1" | sed 's/[^a-zA-Z0-9._-]/_/g'
}

echo ""
echo "Scanning directory: $WALLPAPER_DIR"
echo "Prefix: $PREFIX"
echo "Starting number: $START_NUMBER"
echo "Dry run: $DRY_RUN"
echo "----------------------------------------"

counter=$START_NUMBER
renamed_count=0
skipped_count=0


while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    
    if is_supported_extension "$filename"; then
  
        extension="${filename##*.}"
        
    
        new_filename="${PREFIX}_$(printf "%03d" $counter).${extension,,}"
        new_filename=$(sanitize_filename "$new_filename")
        new_path="$WALLPAPER_DIR/$new_filename"
        
     
        if [[ -e "$new_path" && "$file" != "$new_path" ]]; then
            echo "Warning: '$new_filename' already exists. Skipping '$filename'"
            ((skipped_count++))
            continue
        fi
        
        if [[ "$DRY_RUN" == true ]]; then
            echo "Would rename: '$filename' -> '$new_filename'"
        else
            if mv -n "$file" "$new_path" 2>/dev/null; then
                echo "Renamed: '$filename' -> '$new_filename'"
                ((renamed_count++))
            else
                echo "Error: Failed to rename '$filename'"
                ((skipped_count++))
                continue
            fi
        fi
        
        ((counter++))
    else
        ((skipped_count++))
    fi
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f -print0)

echo "----------------------------------------"
echo "Summary:"
echo "Files processed: $((renamed_count + skipped_count))"
echo "Files renamed: $renamed_count"
echo "Files skipped: $skipped_count"

if [[ "$DRY_RUN" == true ]]; then
    echo "Note: This was a dry run - no files were actually renamed"
fi
