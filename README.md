# orochi-for-medusa

Command-line utilities for Medusa. The utilities list, name, find, move,
and upload Medusa records, much as GNU utilities do for files.

Related projects include
[medusa_rest_client](https://github.com/misasa/medusa_rest_client),
[tepra](https://github.com/misasa/tepra), and
[sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa).

## Requirements

- Ruby 2.6 or later (tested on Ruby 2.6, 2.7, 3.2, 3.3, 3.4, and 4.0)
- The [medusa_rest_client gem](https://github.com/misasa/medusa_rest_client)
- Access to a Medusa server
- For `orochi-label` and `orochi-mkstone`, the [tepra gem](https://github.com/misasa/tepra)
- For `orochi-download` and `.pml` uploads, `casteml`; for `orochi-url`, `curl` and `w3m`

## Installation

Install the gem from the university gem server:

```sh
gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
gem install orochi-for-medusa
```

Verified gems are also available from
[GitHub Releases](https://github.com/misasa/orochi-for-medusa/releases).
Install a downloaded gem with `gem install --local orochi-for-medusa-VERSION.gem`
after installing medusa_rest_client.

The commands read the configuration file `~/.orochirc`, which should look
like this:

```yaml
---
uri: https://dream.misasa.okayama-u.ac.jp/demo
user: admin
password: admin
```

## Commands

| command              | description                                          |
| -------------------- | ---------------------------------------------------- |
| orochi-cd            | Change the orochi working box                        |
| orochi-ditto         | Clone a box recursively                              |
| orochi-download      | Download full datasets for multiple families         |
| orochi-find          | Search Medusa by keyword                             |
| orochi-help          | Show the list of commands                            |
| orochi-image         | Download an image file                               |
| orochi-label         | Create a barcode label with Medusa-ID and stone name |
| orochi-ls            | List box contents                                    |
| orochi-mkstone       | Create a stone (or box) and print a barcode          |
| orochi-mv            | Store a stone in a box                               |
| orochi-name          | Return the name of a record specified by Medusa-ID   |
| orochi-open          | Open records in the default browser                  |
| orochi-place         | Search Medusa and return latitude and longitude      |
| orochi-pwd           | Print the full hierarchy of the orochi working box   |
| orochi-refresh-tile  | Refresh tiles in layers on a surface                 |
| orochi-rename        | Rename a record or change an attribute               |
| orochi-rm            | Remove each specified record                         |
| orochi-stone-in-box  | Convert a stone to a box                             |
| orochi-uniq          | Write only one stone per family                      |
| orochi-upload        | Upload image and CASTEML files to Medusa             |
| orochi-url           | Show a record on standard output using curl and w3m  |

## Usage

Run any command with `--help` for details, for example `orochi-ls --help`.

## Development

### Messages

Print progress messages either to standard output with the verbose option
or to standard error, in the following format:

```ruby
print "--> stonename |#{stonename}|\n" if OPTS[:verbose]
STDERR.print "--> stonename |#{stonename}|\n"
if OPTS[:verbose]
  print "--> parent_obj "
  p parent_obj
end
```

### Test and build

Before committing a change, run the specs. The Gemfile takes
medusa_rest_client from its public GitHub repository, so no access to the
university gem server is needed.

```sh
bundle install
bundle exec rspec
bundle exec rspec spec/orochi_for_medusa/commands/stone_in_box_spec.rb
```

Build the gem and verify its installed commands from the repository root:

```sh
bundle exec rake build
bundle exec ruby script/verify_package.rb pkg/orochi-for-medusa-1.5.5.gem
```

The package check installs the archive into a temporary gem directory and
runs `--help` for every installed command. It does not contact a Medusa
server.

## Build and release on GitHub

GitHub Actions runs the specs on Ruby 2.6.10, 2.7.8, 3.2, 3.3, 3.4, and 4.0,
then builds and verifies the gem. The `orochi-for-medusa-gem` artifact is
available in the **Ruby** workflow run.

A stable `vVERSION` tag on a tested `master` commit also publishes the
verified gem and its SHA-256 manifest to
[GitHub Releases](https://github.com/misasa/orochi-for-medusa/releases).
The tag must match `lib/orochi_for_medusa/version.rb` (for example,
`v1.5.5` for version `1.5.5`). After merging the version change into
`master`, create and push the tag from that commit:

```sh
tag=$(ruby -r ./lib/orochi_for_medusa/version -e 'print "v#{OrochiForMedusa::VERSION}"')
git tag "$tag"
git push origin "refs/tags/$tag"
```

Releases follow the same process as `tepra`, `sisyphus-for-medusa`,
`pmlatex`, and `scalebar`: check the tag, version, `master` ancestry, and
existing releases; upload a draft; download and compare both assets; then
publish. Existing releases (including drafts) and legacy version tags are
never replaced. Use a new version and tag for each release.

## Download and transfer from Jenkins

Use Bash, curl, `shasum`, and `link` to fetch a public Release without a
GitHub token or Ruby. The default selects the latest stable Release; use
`--version` to pin the build to deploy.

```sh
bash script/download_release.sh --output-dir ./downloads
bash script/download_release.sh --version 1.5.5 --output-dir ./downloads-1.5.5
```

The helper verifies the SHA-256 manifest before saving the files. For the
Jenkins transfer step, set `OROCHI_DEPLOY_DEST` to the server and directory
configured for the job, then run the helper with `--deploy`:

```sh
export OROCHI_DEPLOY_DEST='user@server.example.edu:/absolute/web/path'
bash script/download_release.sh --version 1.5.5 --output-dir ./transfer-1.5.5 --deploy
```

The remote parent directory must already exist. Jenkins uses its existing
noninteractive SSH credentials and known host. The helper copies both assets
to a new `vVERSION` subdirectory and refuses existing local files or remote
version directories. After the transfer, update the gem index through the
existing server-side process.

## License

GNU General Public License v3.0 or later. See [LICENSE.txt](LICENSE.txt).
