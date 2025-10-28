import pandas as pd

# Load the Excel file into a DataFrame
file_path = 'ScaleSymb_ed2.xlsx'
df = pd.read_excel(file_path)

# Filter out rows where COG information is missing
df = df.dropna(subset=['COG'])

# Split combined COGs into separate rows
df['COG'] = df['COG'].apply(lambda x: list(x))

# Explode the lists so that each element gets its own row
df_expanded = df.explode('COG')

# Get unique COG categories from Column B
unique_cogs = df_expanded['COG'].unique()

# Create a separate sheet for each COG category
with pd.ExcelWriter('ScaleSymb_ed_sorted.xlsx') as writer:
    for cog in unique_cogs:
        # Select rows where COG column contains the current category
        cog_df = df_expanded[df_expanded['COG'] == cog]

        # Write the DataFrame to a new sheet
        cog_df.to_excel(writer, sheet_name=cog, index=False)

    # Create a sheet for orthologous genes not assigned to any alphabet
    remaining_df = df[df['COG'].apply(lambda x: not any(c.isalpha() for c in str(x)))]
    remaining_df.to_excel(writer, sheet_name='Remaining', index=False)
