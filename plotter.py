import sys
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import os   

# Read arguments
if len(sys.argv) < 4:
    print("Usage: python script.py input_csv xlabel function")
    print("Example: python script.py data.csv 'Vector Size (bytes)' 'Keccak'")
    sys.exit(1)

input_csv_path = sys.argv[1]
x_label = sys.argv[2]
function_type = sys.argv[3]

# Read data from CSV
df = pd.read_csv(input_csv_path)
df['N'] = df['N'].astype(int)

def time_to_seconds(time_str):
    time_str = time_str.strip()
    try:
        if 'm' in time_str:
            parts = time_str.split('m')
            minutes = float(parts[0])
            seconds = 0
            if len(parts) > 1 and parts[1]:
                seconds = float(parts[1].replace('s', ''))
            return minutes * 60 + seconds
        else:
            return float(time_str.replace('s', ''))
    except Exception as e:
        print(f"Error parsing time: {time_str}")
        print(f"Error details: {e}")
        return None

# Apply conversion and print raw values
print("Raw time conversion check:")
for idx, row in df.iterrows():
    seconds = time_to_seconds(row['Time'])
    print(f"{row['Prover']}, N={row['N']}, Time={row['Time']} => {seconds:.1f}s = {seconds/60:.2f}m")

df['Seconds'] = df['Time'].apply(time_to_seconds)
df['Minutes'] = df['Seconds'] / 60

# Print sorted data for validation
print("\nData sorted by Prover and N for validation:")
pd.set_option('display.float_format', '{:.2f}'.format)
validation_df = df.sort_values(['Prover', 'N'])[['Prover', 'N', 'Time', 'Minutes']]
print(validation_df.to_string())

# Set dark mode style
plt.style.use('dark_background')
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd',
          '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf']

# Create single figure with dark background
plt.figure(figsize=(10, 6), facecolor='#1a1a1a')
ax = plt.gca()
ax.set_facecolor('#1a1a1a')

# Function to plot data
def plot_data(ax, data):
    for i, prover in enumerate(data['Prover'].unique()):
        prover_data = data[data['Prover'] == prover].sort_values('N')
        print(f"\nPlotting data for {prover}:")
        print(prover_data[['N', 'Minutes']].to_string())

        ax.loglog(prover_data['N'], prover_data['Minutes'], 'o-',
                 label=prover, linewidth=2, markersize=8,
                 color=colors[i % len(colors)])

# Plot log-log scale
plot_data(ax, df)
ax.set_xlabel(x_label, color='white')
ax.set_ylabel('Time (minutes)', color='white')
ax.set_title(f'{function_type} Performance Comparison (Log-Log Scale)', color='white')
ax.grid(True, alpha=0.2, color='gray')
ax.legend(bbox_to_anchor=(1.02, 1), loc='upper left',
          frameon=True, facecolor='#2d2d2d', edgecolor='white',
          labelcolor='white')

# Set tick colors
ax.tick_params(axis='x', colors='white')
ax.tick_params(axis='y', colors='white')

# Format x-axis to show numbers in millions/thousands
def format_func(x, p):
    if x >= 1_000_000:
        millions = x / 1_000_000
        if millions.is_integer():
            return f'{int(millions)}M'
        else:
            return f'{millions:.1f}M'
    elif x >= 1_000:
        return f'{int(x/1_000)}K'
    return str(int(x))
ax.xaxis.set_major_formatter(ticker.FuncFormatter(format_func))

plt.tight_layout()

# Save the plot to the same folder as the input CSV, with the same name but in PNG format
output_image_path = os.path.splitext(input_csv_path)[0] + '.png'
plt.savefig(output_image_path, dpi=300, bbox_inches='tight', facecolor='#1a1a1a')
print(f"Plot saved to {output_image_path}")

plt.show()
