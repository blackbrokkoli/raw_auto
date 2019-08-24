# zenity --file-selection --directory

# set directory to copy to
originals=$(zenity --file-selection --directory --title="Camera DCIM Directory")
dir=$(zenity --file-selection --directory --title="Target Directory")

# Copy every raw from SD to picture folder
mkdir -p "$dir/../out/all"
find $(echo $originals) -name \*.RW2 -exec cp {} "$dir/../out/all" \;

# Rename all files, based on date
exiftool "$dir"* '-filename<CreateDate' -d %Y%m%d%%-.4nc.%%le -r --verbose

# Get all unique dates, readable in a text file
ls "$dir" | cat | cut -c 1-8 | uniq | sed 's/.\{4\}/&-/' | sed 's/.\{7\}/&-/' > "$dir"/../.temp.txt

# Make directories based on txt
xargs -I {} mkdir -p "$dir/../out/calendar/{}" < "$dir"/../.temp.txt 
xargs -I {} mkdir -p "$dir/../out/best-of/{}" < "$dir"/../.temp.txt 
xargs -I {} mkdir -p "$dir/../out/edited/{}" < "$dir"/../.temp.txt 

# Loop through datelist
while read l; do
  date=$(echo "$l" | sed "s/\-//g")
  echo $date
  mv $(echo "$dir/../out/all/$date*") $(echo "$dir/../out/calendar/$l")
done < "$dir"/../.temp.txt

