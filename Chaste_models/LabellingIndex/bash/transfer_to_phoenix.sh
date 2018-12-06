#!/bin/bash
# gets all the files on phoenix and sends any modifications to phoenix

# transfers data from server to local directory
# ignores hidden folders: -f"- .*/"
# adds non-hidden folders: -f"+ */"
# ignores files in the base directory: -f"- *"
# rsync -avz --progress -f"- .*/" -f"- output/" -f"+ */" -f"+ */*" -f"- *"   a1738927@phoenix.adelaide.edu.au:/fast/users/a1738927/Chaste/projects/ChasteMembrane/ .

# transfers Matlab code for creating the parameter space sweeps
# adds subfolders and their contents: -f"+ */"
# adds .cpp .hpp .txt .py .m and .sh files: -f"+ *.m" -f"+ *.sh"
# ignores any other file eg. pdfs: -f"- *.*"
# removes anything in the destination folder that isn't being transfered: --delete
rsync -avz --progress -f"+ */" -f"+ *.hpp" -f"+ *.cpp" -f"+ *.sh" -f"+ *.txt" -f"+ *.m" -f"+ *.py" -f"- *.*" --delete ../ a1738927@phoenix.adelaide.edu.au:/fast/users/a1738927/Chaste/projects/LabellingIndex/