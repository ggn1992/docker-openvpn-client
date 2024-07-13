#!/usr/bin/env bash

# Directory containing the .conf and .ovpn files
CONFIG_DIR="/config"

# Loop through all .conf and .ovpn files in the directory
for config_file in "$CONFIG_DIR"/*.conf "$CONFIG_DIR"/*.ovpn; do
  # Check if the file exists to handle cases where no matching files are found
  if [[ -f "$config_file" ]]; then
    echo "Processing $config_file"

    # Delete lines containing 'up' or 'down'
    sed -i '/^\s*up\s/d;/^\s*down\s/d' "$config_file"

    echo "Updated $config_file"
  fi
done

echo "Finished processing all configuration files."
