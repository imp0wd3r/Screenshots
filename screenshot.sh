folder=/tmp/screenshot_target
result=$2
if [ ! -d "$folder" ]; then
    mkdir $folder
fi

if [ ! -d "$result" ]; then
    mkdir $result
fi

cd $folder
rm -f *
split -l 5 $1
cd -

for target in "$folder"/*
do
    echo 'Processing' $target
    node screenshot.js $target $result
done
