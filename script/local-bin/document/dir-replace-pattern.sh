#!/usr/bin/env bash
# Replace a pattern in all files inside a directory.
# Run example: `document-dir-replace-pattern "./" "\[NA\]" ""`.

# Check if correct number of arguments provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <directory_path> <pattern_to_replace> <replacement_string>"
    exit 1
fi

dir_path="$1"
pattern_to_replace="$2"
replacement_string="$3"

# Check if directory exists
if [ ! -d "$dir_path" ]; then
    echo "Error: Directory '$dir_path' does not exist."
    exit 1
fi

# Process each file in the directory
for file in "$dir_path"/*; do
    # Skip if it's not a file
    if [ ! -f "$file" ]; then
        echo "skip"
        continue
    fi

    # Get filename without path
    filename=$(basename "$file")

    # Check if pattern matches completely at the beginning of the filename
    if [[ "$filename" =~ ^$pattern_to_replace(.*)$ ]]; then
        # Extract the part after the pattern
        new_filename="${BASH_REMATCH[1]}"

        # Rename the file
        echo "Renaming: $filename -> $new_filename"
        mv "$file" "$dir_path/$new_filename"
    fi
done
