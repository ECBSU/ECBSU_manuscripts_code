# Function to extract values and their corresponding file names
def extract_values_with_filenames(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    values = []
    filename = file_path.split('/')[-1]
    values.append(filename)  # Add the filename once before the value sets
    for line in lines:
        parts = line.split()
        if len(parts) >= 2:  # Ensure there are at least two parts in the line
            value = parts[-1]  # Get the last part
            if value.replace('.', '', 1).isdigit():  # Check if it's a valid floating-point number
                values.append(value)
    return values

# Extract values from the first text file
values_file1 = extract_values_with_filenames('2YN.dN')

# Extract values from the second text file
values_file2 = extract_values_with_filenames('2YN.dS')

# Add a blank row before the filename of the second file
values_file2 = [""] + values_file2

# Combine the values from both files
combined_values = values_file1 + values_file2

# Write the combined values to a new text file
with open('dN,dS_extracted.txt', 'w') as output_file:
    output_file.write("Values from both files:\n")
    output_file.write("\n".join(combined_values))

print("Combined values with filenames saved to dN,dS_extracted.txt")
