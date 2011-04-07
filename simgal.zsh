#! /usr/bin/env zsh

mytitle="Photo Album"
thumbdir="thumbs"
scaledir="scaled"
indexfile="index.html"
stylesheet="http://hack.org/mc/gallery.css"

thumbwidth="150"
thumbheight="150"
scaledwidth="640"
scaledheight="400"

thumbsize="${thumbwidth}x${thumheight}"
scaledsize="${scaledwidth}x${scaledheight}"

mkdir $thumbdir
mkdir $scaledir

# Index HTML header.
{
    echo "<!DOCTYPE html>"
    echo "<html>"
    echo "<head>"
    echo "<meta charset='UTF-8'>"
    echo "<meta http-equiv='content-type' content='text/html; charset=UTF-8'>"
    
    if [ x${stylesheet} != "x" ]
    then
	echo "<link rel='stylesheet' type='text/css' href='$stylesheet'>"
    fi

    echo "<title>$mytitle</title>"
    echo "</head>"
    echo "<body>"
}  > $indexfile 

# Get all image files in the order we want them. Change the options to
# ls if you want them in some other order. Or massage the $images
# array into the order you want. You might, for instance, want to walk
# through the images and look for EXIF timestamps and sort after that
# instead.

images=(`ls -tr *.jpg`)
max=${#images[*]}

echo "Processing $max images."

for ((i=1; i < $max + 1; i=$i + 1))
do
    echo "Processing #${i}, $images[i]"

    f=$images[i]

    # Only create scaled preview if it isn't already there.
    if ! [ -f $scaledir/$f ]
    then
	# Possibly rotate the image first.
    
        # Remember modified time
	mtime=`stat -t "%Y%m%d%H%M.%S" -f %Sm $f`
    
        # Possibly rotate the image.
	jhead -autorot $f

        # Set mtime again
	touch -m -t $mtime $f

	# Now create scaled preview.
	convert $f -thumbnail $scaledsize $scaledir/$f
    fi

    # Only create thumbnail if it isn't already there.
    if ! [ -f $thumbdir/$f ]
    then
	# Create thumbnail from scaled preview.
	convert $scaledir/$f -thumbnail ${thumbsize}^ -gravity center \
	    -extent ${thumbsize} $thumbdir/$f
    fi

    # Get EXIF creation date and any JPEG comment
    exifdata=`jhead $f |awk '/^Date.*/ { print $3,$4 } ; /^Comment/ { print $3 }'`

    # Create HTML file if it isn't there already.
    imagefile="$f.html"
    if ! [ -f $imagefile ]
    then
	{
	    echo "<!DOCTYPE html>"
	    echo "<html>"
	    echo "<head>"
	    echo "<meta charset='UTF-8'>"
	    echo "<meta http-equiv='content-type' content='text/html; charset=UTF-8'>"
    
	    if [ x${stylesheet} != "x" ]
	    then
		echo "<link rel='stylesheet' type='text/css' href='$stylesheet'>"
	    fi

	    echo "<title>$f</title>"
	    echo "</head>" 
	    echo "<body>"

	    # Show a scaled preview of the image.
	    #
	    # Let's not use width and height here, because we don't
	    # know if the convert operation changed it. The image
	    # might be rotated and has a different width now, for
	    # instance.
	    echo "<p> <a href='$f' accesskey='z'><img src='$scaledir/$f' alt='Preview of $f'></a> </p>"

	    echo "<pre>$exifdata</pre>"

	    echo "<p>"

	    # If this isn't the first image, link to the previous
	    # image with a thumbnail.
	    if [ $i != 1 ]
	    then
		echo "<a href='$images[$i - 1].html' accesskey='p'><img src='thumbs/$images[$i - 1]' width='$thumbwidth' height='$thumbheight' alt='Previous'></a>"
	    else
		echo "No previous."
	    fi

	    # If this isn't the last image, link to the next image
	    # with a thumbnail.
	    if [ $i != $max ]
	    then
		echo "<a href='$images[$i + 1].html' accesskey='n'><img src='thumbs/$images[$i + 1]' width='$thumbwidth' height='$thumbheight' alt='Next'></a>"
	    else
		echo "No next."
	    fi

	    echo "</p>"

	    echo "<p> <a href='index.html' accesskey='u'>Up to Album Index</a> </p>"  
	    echo "<p> <strong>U</strong>: Up <strong>N</strong>: Next <strong>P</strong>: Previous <strong>Z</strong>: Zoom </p>"
	    echo "</body>"
	    echo "</html>"
	} > $imagefile
    fi

    # Add a thumbnail image to the index.
    #
    # Better use width and height here. If some images are smaller
    # than $thumbsize they will stretch but the index will still load
    # much faster.
    echo "<a href='$imagefile'><img src='$thumbdir/$f' width='$thumbwidth' height='$thumbheight'></a>" >>$indexfile
done

# Index HTML footer.
{
    echo "<p> <a href='../' accesskey='u'>Up to Directory</a> </p>"
    echo "<p> <a href='zshgal-help.html' accesskey='h'>Help</a></p>"
    echo "</body>"
    echo "</html>"
} >>$indexfile 
