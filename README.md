# Stackstream

Infrastructure as code. 

## Why?

While walking down the Automation street in the city called DevOps I passed
by a shop called [Chef]. This shop was fantasic! I was able to pick up many
ready to use cookbooks to manage items in my kitchen. Not soon after I had
everything automated from the light switch to the refrigerator. Though, after
sometime I found myself needing to manage more than just my kitchen. I tried
to extend my kitchen automation, but it was awkward and uncomfortable at times.

One day I'm walking down that same street and find a shop called [Terraform].
This shop was fantasic! I could now manage items in my kitchen, the kitchen
itself and everything else in my home! I could even manage my vacation home,
[Terraform] didn't care if the home was built by a different contractor!
But of course, after sometime I wasn't satisifed with managing each item
and room.

I wished to have the simpler days back! However, thinking back on those days
nothing was any easier, they were just different. [Chef]'s shop was painted
bright orange in the beginning, but after thousands of visitors, it's glow is
a bit dimished. [Terraform]'s shop was painted deep dark purple, but after
thousands of customers, it's deep colors are a bit dull. Both have
great products and both have faults. No product will be perfect, no
two things function the same, but are there commonalities between the two?
What is the vision to takeaway from their successes and failures?

[Chef]: chef.io
[Terraform]: terraform.io

## Goals

* Provide tooling around standard methodologies of orchestrating infrastructure as code
* Create a provider agnostic DSL for deploying infrastructure and apps

## Installation

stackstream is packaged as a cryptographically signed Ruby gem which means
it can be [installed with Bundler] or [RubyGems].

Command line:

```sh
gem install stackstream
```

Gemfile.rb:

```rb
gem 'stackstream'
```

[installed with Bundler]: https://bundler.io/index.html#getting-started
[RubyGems]: http://guides.rubygems.org/rubygems-basics/#installing-gems

## Usage

```sh
stackstream project new my_simple_infrastructure
```

Refer to the [examples directory] for detailed example projects.

[examples directory]: examples/

### Write a stack

Using a [Ruby] DSL                                                                                                             

[Ruby]: ruby-lang.org
