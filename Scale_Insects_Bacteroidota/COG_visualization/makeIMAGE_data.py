import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Read the Excel file into a pandas DataFrame
df = pd.read_excel('DATA_byPhylogeny_reordered_0or1.xlsx', header=None)  # Replace 'your_excel_file.xlsx' with your actual file path

# Create figure and axis without boundary and axis
fig, ax = plt.subplots(frameon=False)
ax.axis('off')

# Determine cell size and padding for squares
cell_size = 1
padding = 0.1
border_thickness = 0.01  # Thickness of the cell boundaries

# Define partitions and their corresponding row ranges
partitions = {
    'L': list(range(1, 86)),
    'K': list(range(87, 121)),
    'J': list(range(122, 256)),
    'O': list(range(257, 302)),
    'E': list(range(303, 425)),
    'G': list(range(426, 484)),
    'I': list(range(485, 527)),
    'H': list(range(528, 628)),
    'F': list(range(629, 684)),
    'P': list(range(685, 750)),
    'Q': list(range(751, 767)),
    'C': list(range(768, 855)),
    'M': list(range(856, 966)),
    'U': list(range(967, 1004)),
    'T': list(range(1005, 1027)),
    'D': list(range(1028, 1048)),
    'V': list(range(1049, 1065)),
    'N': list(range(1066, 1072)),
}

# Define unique colors for each partition
partition_colors = {
    'L': '#1f77b4',  # Blue
    'K': '#ff7f0e',  # Orange
    'J': '#2ca02c',  # Green
    'O': '#d62728',  # Red
    'Q': '#9467bd',  # Purple
    'F': '#8c564b',  # Brown
    'E': '#e377c2',  # Pink
    'G': '#7f7f7f',  # Grey
    'I': '#bcbd22',  # Olive
    'H': '#17becf',  # Cyan
    'P': '#FF7675',  # Lighter Blue
    'C': '#F39C12',  # Lighter Orange
    'M': '#2C3E50',  # Lighter Green
    'U': '#FF1493',  # Deep Pink
    'T': '#4682B4',  # Steel Blue
    'D': '#FF6347',  # Tomato
    'V': '#00FA9A',  # Medium Spring Green
    'N': '#B22222',  # Fire Brick
}
    
# Define spacing between partitions
partition_spacing = 5  # Number of empty rows between partitions

# Loop through each cell and plot squares with different colors for different partitions
for i in range(df.shape[0]):
    for j in range(df.shape[1]):
        for partition, row_numbers in partitions.items():
            if i + 1 in row_numbers and df.at[i, j] == 1:
                facecolor = partition_colors[partition]
                square = patches.Rectangle((j + padding, df.shape[0] - i - 1 + padding), cell_size - 2*padding, cell_size - 2*padding, linewidth=border_thickness, edgecolor='white', facecolor=facecolor)
                ax.add_patch(square)
                break
        else:
            square = patches.Rectangle((j + padding, df.shape[0] - i - 1 + padding), cell_size - 2*padding, cell_size - 2*padding, linewidth=border_thickness, edgecolor='white', facecolor='#D3D3D3')  # Use lighter grey color
            ax.add_patch(square)

# Set x and y axis limits based on the number of rows and columns
ax.set_xlim(0, df.shape[1])
ax.set_ylim(0, df.shape[0])

# Save the plot as a PDF file
plt.savefig('DATA_byPhylogeny_reordered_0or1_image.pdf')
