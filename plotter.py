import sys
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import os

# Read arguments
if len(sys.argv) < 4:
    print("Usage: python script.py input_csv xlabel function [--linear]")
    print("Example: python script.py data.csv 'Vector Size (bytes)' 'Keccak' [--linear]")
    sys.exit(1)

input_csv_path = sys.argv[1]
x_label = sys.argv[2]
function_type = sys.argv[3]
linear_scale = '--linear' in sys.argv  # Check for --linear flag

# Read data from CSV
df = pd.read_csv(input_csv_path)

# Dynamically find the column name ('N' or 'Megagas')
column_name = next((col for col in df.columns if col in ['N', 'Megagas']), None)
if column_name is None:
    raise ValueError("Neither 'N' nor 'Megagas' column found in the DataFrame")

# Convert the column to integer
df[column_name] = df[column_name].astype(int)

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
    print(f"{row['Prover']}, {column_name}={row[column_name]}, Time={row['Time']} => {seconds:.1f}s = {seconds/60:.2f}m")

df['Seconds'] = df['Time'].apply(time_to_seconds)
df['Minutes'] = df['Seconds'] / 60

# Print sorted data for validation
print(f"\nData sorted by Prover and {column_name} for validation:")
pd.set_option('display.float_format', '{:.2f}'.format)
validation_df = df.sort_values(['Prover', column_name])[['Prover', column_name, 'Time', 'Minutes']]
print(validation_df.to_string())

# Set style and color cycle
plt.style.use('tableau-colorblind10')
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']

# Create single figure
plt.figure(figsize=(10, 6))
ax = plt.gca()

# Function to plot data
def plot_data(ax, data, use_linear=False):
    for i, prover in enumerate(data['Prover'].unique()):
        prover_data = data[data['Prover'] == prover].sort_values(column_name)
        print(f"\nPlotting data for {prover}:")
        print(prover_data[[column_name, 'Minutes']].to_string())

        if use_linear:
            ax.plot(prover_data[column_name], prover_data['Minutes'], 'o-',
                    label=prover, linewidth=2, markersize=8,
                    color=colors[i % len(colors)])
        else:
            ax.loglog(prover_data[column_name], prover_data['Minutes'], 'o-',
                     label=prover, linewidth=2, markersize=8,
                     color=colors[i % len(colors)])

# Plot with chosen scale
plot_data(ax, df, use_linear=linear_scale)
ax.set_xlabel(x_label)
ax.set_ylabel('Time (minutes)')
scale_label = 'Linear Scale' if linear_scale else 'Log-Log Scale'
ax.set_title(f'{function_type} Performance Comparison ({scale_label})')
ax.grid(True, alpha=0.3)
ax.legend(bbox_to_anchor=(1.02, 1), loc='upper left')

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
plt.savefig(output_image_path, dpi=300, bbox_inches='tight')
print(f"Plot saved to {output_image_path}")

plt.show()
