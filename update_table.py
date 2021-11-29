""" 
Date: 2021-11-29

Update the app table with all accepted apps in the accepted apps folder.
"""

import os
import re

os.chdir(os.path.dirname(os.path.abspath(__file__)))

def parse_info(info: str) -> dict:
    """Receive string from an accepted-apps file
    and parse it into a dictionary. 
    
    Params:
    -------
    info: str
        a string from accepted-apps file
    
    Returns:
    --------
    a dictionary with the tags and associated info.
    """
    
    app_info = {}
    tags = re.findall("- [ A-Z()-]+:", info)
    for tag in tags[::-1]:
        info = info.split(tag)
        app_info[re.match("- (.*):", tag).group(1)] = info[1].strip()
        info = info[0]

    return app_info

if __name__ == "__main__": 
    
    table_entries = []
    with open("README.md", mode = "r") as readme:
        readme_text = readme.read()
        table_separator = re.findall("\\n-+.*-+\\n",readme_text)[0]    
        
        for app_file in os.listdir("accepted-apps"):
            with open(file="accepted-apps/" + app_file, mode = "r") as file:
                info = file.read()
                app_info = parse_info(info)
                table_entries.append(
                    f"[{app_info['TITLE']}]({app_info['LINK TO DEPLOYED APP']}) | " + 
                    "<ul>" + f"{''.join(['<li>' + topic.title() + '</li>' for topic in app_info['MAIN TOPIC'].split(',')])}" + "</ul> | " +
                    "[link](https://github.com/UBC-STAT/shiny-apps/blob/main/accepted-apps/" + f"{app_file}) | " + 
                    f"{app_info['AUTHOR(S)']} | " + 
                    f"{'[Repo](' + app_info['LINK TO REPOSITORY'] + ')' if app_info['LINK TO REPOSITORY'] else '-' }"
                )
        
    readme_split = readme_text.split(table_separator)

    with open("README.md", mode = "w") as readme:
        readme.write(readme_split[0] + table_separator + "\n".join(table_entries))

    os.system('git add README.md')
    os.system('git commit -m "Update apps table"')
    os.system('git push')

