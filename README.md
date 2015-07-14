# Orochi

Provide command-line interface to Medusa

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orochi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orochi

## Commands

Commands are summarized as:

| command              | description                                      |
| -------------------- | ------------------------------------------------ |
| orochi-cd            | Change the orochi working box                    |
| orochi-ditto         | Clone box recursively                            |
| orochi-find          | Search Medusa by keyword                         |
| orochi-label         | Create barcode label of Medusa-ID and stone-name |
| orochi-ls            | List box contents                                |
| orochi-machine       | Start or stop machine session                    |
| orochi-mkstone       | Create a stone (or box) and print barcode        |
| orochi-mv            | Store a stone to a box                           |
| orochi-name          | Return name of record specified by Medusa-ID     |
| orochi-open          | Open record by default browser                   |
| orochi-pwd           | Print name of the orochi working box             |
| orochi-rename        | Rename record or change attribute                |
| orochi-rm            | Remove each specified record                     |
| orochi-upload        | Upload jpg files in current directory            |
| orochi-url           | Retrive url using curl and w3m                   |
| orochi-stone-in-box! | Convert stone to box                             |
| orochi-download      | Download full datasets for polyfamilies          |
| stone                | Update location of a stone                       |
| stones               | Do inventory count                               |


## Usage

See online document with option `--help`.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/orochi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request