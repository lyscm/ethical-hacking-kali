# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
import json
import os
    
# %%
def get_settings(dict):

    dict_type = "settings"

    settings = dict[dict_type]

    # Create directory
    settings_dir = ".vscode-configurations"
    if not os.path.exists(settings_dir):
        os.makedirs(settings_dir)    
    
    # Write settings
    settings_path = os.path.join(settings_dir, "{}.json".format(dict_type))
    with open(settings_path, 'w') as file:
        json.dump(settings, file, indent=4)

# %%
# Define a filename.
filename = ".devcontainer/devcontainer.json"

# Open the file as f.
# The function readlines() reads the file.
with open(filename, 'r') as file:
    content = file.read()

container_dict = json.loads(content)

# Settings
get_settings(container_dict)

# %%