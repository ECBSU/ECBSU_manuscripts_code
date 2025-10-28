import os

# Function to sort filenames based on the number after 'Ortho' in the filename
def sort_filenames(filenames):
    """
    Sort filenames based on the number after 'Ortho' in the filename.
    """
    valid_filenames = []
    for filename in filenames:
        try:
            # Extract the number after 'Ortho' and sort by that number
            num = int(filename.split('_')[0].replace('OG', ''))
            valid_filenames.append((filename, num))
        except ValueError:
            print(f"Warning: Skipping invalid filename '{filename}'")
    
    # Sort the valid filenames based on the extracted number
    sorted_filenames = [filename for filename, _ in sorted(valid_filenames, key=lambda x: x[1])]
    return sorted_filenames

# Get a list of all _pal2nal.fa files in the directory
files = [filename for filename in os.listdir() if filename.endswith('_pal2nal.fa')]

# Print out all files found for debugging
print("Files found:", files)

# Sort the filenames
sorted_files = sort_filenames(files)

if sorted_files:
    # Concatenate the content of all files in order
    concatenated_content = ''
    for filename in sorted_files:
        with open(filename, 'r') as file:
            content = file.read()
            concatenated_content += content

    # Write the concatenated content to a new file
    with open('all_pal2nal.fa', 'w') as output_file:
        output_file.write(concatenated_content)

    print(f"Concatenated content saved to all_pal2nal.fa. Processed files: {sorted_files}")
else:
    print("No valid files found for concatenation.")
