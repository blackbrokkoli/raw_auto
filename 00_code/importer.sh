# BLOCK: Choose the camera/SD root directory

cameraRootDir=$(zenity --file-selection --directory --title="Choose root camera/SD directory") 

if [ "$cameraRootDir" == "" ]
then
    echo -e "\e[1mNothing selected, I will terminate now"
    exit 1
else
    echo -e "\e[1m\e[33m $cameraRootDir \e[39m was selected as the directory I will copy from.\e[21m"
fi



# BLOCK: Make a filelist of all files from the camera
# TODO: Some kind of Filetype selector

pathCameraPathList="../01_workfiles/camera_pathlist.txt"
pathCameraFileList="../01_workfiles/camera_filelist.txt"
pathFolderFileList="../01_workfiles/folder_filelist.txt"
pathNewFileList="../01_workfiles/new_filelist.txt"
pathDateList="../01_workfiles/datelist.txt"
# Directory paths
pathAll="../02_data/all-temp"
pathCalendar="../02_data/calendar"
mkdir -p "$pathAll" "$pathCalendar"


find "$cameraRootDir/" -iname "*rw2" > $pathCameraPathList
echo "..."
echo -e "\e[1mI made a filelist, you should see the first 5 files I found in your source below (showing only new files):\e[21m"
# shorten path to only filename
cat "$pathCameraPathList" | sed -n 's/.*\(\/[a-zA-Z0-9-]*\.rw2\).*/\1/p' | sed 's/\///g' | sort -d > $pathCameraFileList
# make list only with files which are not yet in the directory
comm -23 "$pathCameraFileList" "$pathFolderFileList" 2>/dev/null > "$pathNewFileList"
cat "$pathNewFileList" | head -n 5

echo "..."

# Copy to all directory based on new-files-list
find "$cameraRootDir/" |  grep -f "$pathNewFileList" | xargs -I % cp % "$pathAll"
# Add the now copied file to the list of files existing in the folder
# TODO: Need a truly unique identifier for photos and/or an option to clear this
cat "$pathNewFileList" >> "$pathFolderFileList"

# BLOCK: generate date directories

# Rename all files, based on date
exiftool "$pathAll"* '-filename<CreateDate' -d %Y%m%d%%-.4nc.%%le -r  > /dev/null 2>&1
# Get all unique dates, readable in a text file
ls "$pathAll" | cat | cut -c 1-8 | uniq | sed 's/.\{4\}/&-/' | sed 's/.\{7\}/&-/' > "$pathDateList"


echo -e "\e[1mI am trying to make folders for all dates you took photos on and put them in"
echo -e "If there are any, they are listed below:\e[21m"
while read l 
do 
    date=$(echo "$l")
    echo $date
    mkdir -p "$pathCalendar/$date/all" "$pathCalendar/$date/edited" "$pathCalendar/$date/best-of"
    dateClean=$(echo "$l" | sed "s/\-//g")
    # first filepath has to go through echo for some reason while using mv
    mv $(echo "$pathAll/$dateClean*") "$pathCalendar/$date/all"
done < "$pathDateList"

echo ""

echo -e "\e[1m\e[32mI copied your photos into their date directories in the 'all' folder - Have fun! :)"