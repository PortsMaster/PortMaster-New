from PIL import Image
import os

def halve_png_resolution_in_folder(folder_path):
    # Get all PNG files in the folder
    png_files = [f for f in os.listdir(folder_path) if f.endswith('.png')]

    for png_file in png_files:
        input_path = os.path.join(folder_path, png_file)

        # Open the image
        with Image.open(input_path) as img:
            # Calculate the new dimensions
            new_width = img.width // 2
            new_height = img.height // 2

            # Resize the image
            img_resized = img.resize((new_width, new_height), Image.LANCZOS)

            # Overwrite the original image
            img_resized.save(input_path, optimize=True)
            print(f"Processed and overwritten: {png_file}")

# Example usage
folder_path = os.path.dirname(os.path.abspath(__file__))  # Current folder containing the script
halve_png_resolution_in_folder(folder_path)

print("Halving resolution for all PNG files in the folder is complete!")
