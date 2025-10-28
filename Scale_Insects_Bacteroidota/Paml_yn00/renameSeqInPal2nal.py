def modify_sequence_names(input_file, output_file):
    with open(output_file, 'w') as output_handle:
        with open(input_file, 'r') as input_handle:
            for line in input_handle:
                line = line.strip()
                if line.startswith('>'):
                    truncated_name = line.split('_')[0]
                    output_handle.write(f">{truncated_name}\n")
                else:
                    output_handle.write(line + "\n")

# Specify input and output file paths
input_file = 'all_pal2nal.fasta'
output_file = 'all_pal2nal_renamed.fasta'

# Call the function to modify sequence names
modify_sequence_names(input_file, output_file)
