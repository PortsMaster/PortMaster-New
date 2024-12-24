import json
import os

def set_scale_to_2_in_jsons(folder_path):
    # Get all JSON files in the folder
    json_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]

    for json_file in json_files:
        file_path = os.path.join(folder_path, json_file)

        # Open and parse the JSON file
        with open(file_path, 'r') as file:
            data = json.load(file)

        # Update the "scale" value to 2 if it exists
        if "scale" in data:
            data["scale"] = 2

        # Overwrite the JSON file with the updated data
        with open(file_path, 'w') as file:
            json.dump(data, file, indent=4)

        print(f"Processed and overwritten: {json_file}")

# Example usage
folder_path = os.path.dirname(os.path.abspath(__file__))  # Current folder containing the script
set_scale_to_2_in_jsons(folder_path)

print("Updated scale values to 2 in all JSON files in the folder!")
