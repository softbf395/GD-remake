import os
import base64
import zlib
import requests

def decrypt(data):
    return zlib.decompress(base64.b64decode(data.replace('-', '+').replace('_', '/').encode())[10:], -zlib.MAX_WBITS)

# Specify the path to the encrypted levels and output directory
encrypted_levels_dir = 'encrypted_lvls'
output_dir = 'GDRemake/ios/code/levels'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Loop through all files in the encrypted levels directory
for filename in os.listdir(encrypted_levels_dir):
    if filename.endswith('.gmd'):
        with open(os.path.join(encrypted_levels_dir, filename), 'r') as file:
            encrypted_data = file.read()
        
        decrypted_data = decrypt(encrypted_data)
        
        # Save the decrypted data to a new file
        output_file_path = os.path.join(output_dir, filename)
        with open(output_file_path, 'wb') as output_file:
            output_file.write(decrypted_data)

print("Decryption complete. Decrypted levels saved in:", output_dir)
