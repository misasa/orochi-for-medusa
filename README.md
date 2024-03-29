# gem package -- orochi-for-medusa

Ruby package to manipulate records in Medusa.

# Description

A series of command-line utilities that manipulates records in Medusa.
The utilities list, name, and find records in Medusa as GNU utilities
do to files.

# Dependency

Ruby 2.5, 2.6, or 2.7.

## [gem package -- medusa_rest_client](https://github.com/misasa/medusa_rest_client)

## [gem package -- tepra](https://github.com/misasa/tepra)

# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
    $ gem install orochi-for-medusa

The program reads a configuration file `~/.orochirc`.  The file should look like below.

    ---
    uri: https://dream.misasa.okayama-u.ac.jp/demo
    user: admin
    password: admin

# Commands

Commands are summarized as:

| command              | description                                      |
| -------------------- | ------------------------------------------------ |
| orochi-cd            | Change the orochi working box                    |
| orochi-ditto         | Clone box recursively                            |
| orochi-download      | Download full datasets for poly families         |
| orochi-find          | Search Medusa by keyword                         |
| orochi-help          | Show series of commands                          |
| orochi-label         | Create barcode label of Medusa-ID and stone-name |
| orochi-ls            | List box contents                                |
| orochi-mkstone       | Create a stone (or box) and print barcode        |
| orochi-mv            | Store a stone to a box                           |
| orochi-name          | Return name of record specified by Medusa-ID     |
| orochi-open          | Open record by default browser                   |
| orochi-place         | Search Medusa and return latitude and longitude  |
| orochi-pwd           | Print name of the orochi working box             |
| orochi-refresh-tile  | Refresh tiles in layers on a surface             |
| orochi-rename        | Rename record or change attribute                |
| orochi-rm            | Remove each specified record                     |
| orochi-stone-in-box  | Convert stone to box                             |
| orochi-uniq          | Repeat only one stone in family                  |
| orochi-image         | Download image files in current directory        |
| orochi-upload        | Upload jpg files in current directory            |
| orochi-url           | Show record in standard output by curl and w3m   |


# Usage

See online document with option `--help`.

# Guideline for development

## show message on run
Show message either on standard input with verbose option or standard error as following format.

    print "--> stonename |#{stonename}|\n" if OPTS[:verbose]
    STDERR.print "--> stonename |#{stonename}|\n"
    if OPTS[:verbose]
      print "--> parent_obj "
      p parent_obj
    end

## Test locally
Before commit the revision, test the code by following method using rspec.

    $ cd ~/devel-godigo/orochi-for-medusa
    $ bundle install --path vendor/bundler
    $ bundle exec rspec spec/orochi_for_medusa/commands/stone_in_box_spec.rb
    $ bundle exec rspec spec/orochi_for_medusa/commands/stone_in_box_spec.rb --tag show_help:true
