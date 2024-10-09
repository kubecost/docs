# Find all images in the .gitbook/assets and images directories
find .gitbook/assets -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" \) > images_list.txt
find images -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" \) >> images_list.txt


# Check each image for references in the site files and identify unreferenced images
while read image; do
  image_name=$(basename "$image")
  if ! grep -r --include=\*.md "$image_name" . > /dev/null; then
    echo "$image_name is not referenced in any file."
  fi
done < images_list.txt