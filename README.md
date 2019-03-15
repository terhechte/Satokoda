# Satokoda

Satokoda is a small tool to set `ID3` tags on MP3 files from a commandline interface.
It is limited to the necessary tags required for the [Contravariance](https://contravariance.rocks) 
Podcast. However, feel free to create a pull request to extend the options.

## Usage

Satokoda has two different inputs for the MP3 tags. 

- Static inputs: These are usually the same for each episode in a podcast (i.e. the podcast title). They are
  defined in a [`.toml`](https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.5.0.md) TOML
  file.
- Dynamic inputs: They change each episode. They're provided as command line flags to `Satokoda`.

Here is a example `toml` file with the currently known tags:

``` TOML
# The cover image for the mp3
image_path = "/tmp/my_podcast_image"

# The year of podcast production
year = 2019

# The album for the podcast
album = "The Name of my Podcast"

# The artist for the podcast
artist = "My Name"
```

Then, `Satokoda` can be called with command line parameters to provide the remaining
parameter (the current `title` of this episode):

``` bash
usage: satokoda [<option> ...] [---] [<program> <arg> ...]
options:
  -h, --help
      Show description of usage and options of this tools.
  -f, --filepath <value>
      The mp3 file to update
  -t, --title <value>
      The title of the episode
  -c, --configpath <value>
      The yaml configuration path
```

Here is an example incantation of `Sakotoda`:

``` bash
satokoda -f ~/Desktop/episode_14.mp3 -t "14: What is your name" -c ./config.toml
```

`Satokoda` will write the `ID3` tags into your MP3 file.

License: MIT
