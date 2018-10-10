# Capistrano::Typo3 [![Code Climate](https://codeclimate.com/github/t3labcom/capistrano-typo3/badges/gpa.svg)](https://codeclimate.com/github/t3labcom/capistrano-typo3) [![Issue Count](https://codeclimate.com/github/t3labcom/capistrano-typo3/badges/issue_count.svg)](https://codeclimate.com/github/t3labcom/capistrano-typo3)

Capistrano Plugin for TYPO3 deployment and development.

## Features

- ease setup of development environment
- deployment model
- lots of utility tasks optimized for typo3

https://rubygems.org/gems/capistrano-typo3

## Compatibility

The versions below have been tested with capistrano-typo3

- TYPO3 6.2.x
- TYPO3 7.x
- TYPO3 8.x
- TYPO3 9.x

##  Configuration

At the top of lib/capistrano/tasks/typo3.cap all variables are listed
and set to a default value.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-typo3'
```

And then execute:

    $ bundle

## Usage

### TYPO3.Homestead

Capistrano-typo3 integrates TYPO3.Homestead. Here's the [Dutch documentation](docs/homestead_nl.md)
about this integrations. English version will follow soon.

## References / inspiration
* https://github.com/programmerqeu/capistrano-typo3-cms
* http://webdesign.about.com/od/servers/qt/web-servers-and-workflow.htm
* https://marketpress.com/2013/deploying-wordpress-with-git-and-capistrano/
* http://www.slideshare.net/jsegars/site-development-processes-for-small-teams
* http://www.zodiacmedia.co.uk/blog/capistrano-3-tutorial-series-part-2
* http://www.slideshare.net/aoemedia/2013-11-typo3-camp-pl
* http://stackoverflow.com/questions/9860593/deploying-multiple-applications-into-a-single-tree-with-capistrano-and-git
* http://stackoverflow.com/questions/11905360/how-best-to-manage-typo3-installations-using-git

![image](http://picdrop.t3lab.com/1ut2sCxI6E.png)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-typo3/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
