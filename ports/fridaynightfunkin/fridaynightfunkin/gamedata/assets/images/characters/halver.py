import os
import xml.etree.ElementTree as ET

def halve_resolution_in_folder(folder_path):
    # Get all XML files in the folder
    xml_files = [f for f in os.listdir(folder_path) if f.endswith('.xml')]

    for xml_file in xml_files:
        input_path = os.path.join(folder_path, xml_file)

        # Parse the XML file
        tree = ET.parse(input_path)
        root = tree.getroot()

        # Iterate over each SubTexture element and modify its attributes
        for sub_texture in root.findall('SubTexture'):
            for attr in ['x', 'y', 'width', 'height', 'frameX', 'frameY', 'frameWidth', 'frameHeight']:
                if attr in sub_texture.attrib:
                    sub_texture.attrib[attr] = str(int(int(sub_texture.attrib[attr]) / 2))

        # Overwrite the original XML file
        tree.write(input_path, encoding='utf-8', xml_declaration=True)
        print(f"Processed and overwritten: {xml_file}")

# Example usage
folder_path = os.path.dirname(os.path.abspath(__file__))  # Current folder containing the script
halve_resolution_in_folder(folder_path)

print("Halving resolution for all XML files in the folder is complete!")