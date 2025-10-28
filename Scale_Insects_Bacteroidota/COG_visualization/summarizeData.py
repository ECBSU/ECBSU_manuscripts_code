import pandas as pd

# Read the Excel file into a pandas DataFrame
df = pd.read_excel('Orthogroups-COGs_summary.xlsx')

# Function to collapse consecutive repeating letters to a single letter
def collapse_repeating_letters(combined_letters):
    result = []
    current_letter = None
    for letter in combined_letters:
        if letter != current_letter:
            result.append(letter)
            current_letter = letter
    return ''.join(result)

# Function to collapse sequences of different letters to a single letter for each sequence
def collapse_different_sequences(combined_letters):
    result = []
    current_sequence = []
    for letter in combined_letters:
        if not current_sequence or letter in current_sequence:
            current_sequence.append(letter)
        else:
            result.append(''.join(set(current_sequence)))  # Remove duplicates within the sequence
            current_sequence = [letter]
    result.append(''.join(set(current_sequence)))  # Remove duplicates within the last sequence
    return ''.join(result)

# Apply the functions to collapse letters and create the 'Final_Column'
df['Combined_Letters'] = df.apply(lambda row: ''.join(str(cell) for cell in row[1:17] if isinstance(cell, (str, int))), axis=1)
df['Final_Column'] = df['Combined_Letters'].apply(lambda x: collapse_different_sequences(collapse_repeating_letters(x)))

# Save the DataFrame to a new Excel file with the 'openpyxl' engine and keep the order of rows
df.to_excel('Orthogroups-COGs_summary_out.xlsx', index=False, engine='openpyxl')
