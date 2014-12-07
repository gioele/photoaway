photoaway: Copy your photo and organize them. Stop.
===================================================

photoaway is a small program that does only one thing: it copies your
photos from your camera or a SD card to your disk, organizing them in
folders based on the pictures' metadata.

No image viewers, no post-processing, only file organization.


Usage
-----

The first thing to do is to set up photoaway.

The default configuration file is `~/.config/photoaway/config`. Mine
contains the following configuration:

    mode = copy
    verbose = true
    root = "~/Documents/Negatives"
    directory_template = "%{Y}-%{m}-%{d}/%{camera_maker} %{camera_model}"

Once photoaway is configured, we invoke it with the directory that contains
the photos as the first argument. The following command will copy all the
valid images from the `/media/PANA-LF1` directory to `~/Documents/Negatives`.

    $ photoaway /media/PANA-LF1
    Metadata error in /media/PANA-LF1/DCIM/P1010521.JPE, skipping.
    copying /media/PANA-LF1/DCIM/101_PANA/P1010522.JPG to
        ~/Documents/Negatives/2014-02-18/Panasonic DMC-LF1/P1010522.JPG
    copying /media/PANA-LF1/DCIM/101_PANA/P1010522.RW2 to
        ~/Documents/Negatives/2014-02-18/Panasonic DMC-LF1/P1010522.RW2

    Summary:
        Could not process 1 files (out of 3 total files)

The path of the destination directory of each image can be configured
via the `directory_template` setting, using pieces of metadata from the
embedded Exif.


Path configuration
------------------

The following keys can be used in the definition of the path of the
destination directory:

`Y`
: The year when the photo has been shot (4-digit format);

`m`
: The month when the photo has been shot (2-digit format);

`d`
: The day of the month when the photo has shot (2-digit format);

`camera_maker`
: A string identifying the maker of the camera, for example
  "Panasonic", "Nikon", "Nokia";

`camera_model`
: A string identifying the model of the camera, for example
  "DMC-LF1", "D90", "N8".


### Examples templates

* `%{Y}-%{m}-%{d}`: `2014-02-11`, `2013-06-20`, `2010-11-28`;
* `%{camera_model}/%{Y}/%{m}-%{d}`: `DMC-LF1/2014/02-01`,
  `D90/2013/06-20`, `N8/2010/11-28`.


Installation
------------

    gem install photoaway


Authors
-------

* Gioele Barabucci <http://svario.it/gioele> (initial author)


Development
-----------

Code
: <https://github.com/gioele/photoaway>

Report issues
: <https://github.com/gioele/photoaway/issues>

Documentation
: <http://rubydoc.info/gems/photoaway>


License
-------

This is free software released into the public domain (CC0 license).

See the `COPYING.CC0` file or <http://creativecommons.org/publicdomain/zero/1.0/>
for more details.
