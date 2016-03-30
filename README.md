Readme
=======

Getting Started
---------------

### Setup RVM

Install via the instructions on the [RVM Homepage][] to install. On Linux, do
not use the version provided via apt-get.

Install and configure your default ruby. As of this writing we are using
MRI 2.0.0-p247.

[RVM Homepage]: http://rvm.io/

### Install PhantomJS

[PhantomJS][] is a headless webkit implementation used for running integration
tests that require javascript.

On **OS X**, install with [Homebrew][]

``` sh
$ brew install phantomjs
```

As of this commit, 2.0.0 binary packages for **Linux** are still being prepared. PhantomJS
recommends building the Linux version from source in the meantime.

``` sh
$ cd /usr/local/share
$ sudo apt-get install build-essential g++ flex bison gperf ruby perl \
  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
  libpng-dev libjpeg-dev
$ git clone git://github.com/ariya/phantomjs.git
$ cd phantomjs
$ git checkout 2.0
$ ./build.sh
$ cd ..
$ cd /usr/local/share && sudo ln -s /usr/local/share/phantomjs/bin/phantomjs
$ cd /usr/local/bin && sudo ln -s /usr/local/share/phantomjs/bin/phantomjs
$ cd /usr/bin && sudo ln -s /usr/local/share/phantomjs/bin/phantomjs
```

[PhantomJS]: http://phantomjs.org/
[Homebrew]: http://brew.sh/

## Install Redis
Redis is used to run Action Cable, which provides server-side reactivity.

To install Redis:

Mac:

``` sh
brew install redis
```

Ubuntu:

``` sh
sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt-get update
sudo apt-get install redis-server
```

Check the version with:

``` sh
redis-cli -v
```

If this returns `redis-cli 2.6` or above, you should be all set. If you are having
trouble with the `sudo add-apt-repository`, try these two commands:

``` sh
sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
```

and try again.

Execute `redis-server` in a free terminal window and you should see redis
start normally. Then, restart your dev server to start using redis!

If you're looking to utilize the reactive behavior of Action Cable, remember to run your dev
server using foreman, to ensure that Sidekiq workers are started as well. 

## Clone the application
```sh
$ git clone git@github.com/jprince/sleepers-and-keepers.git
```

## Setup your environment
```sh
$ ./bin/setup
```

## Set your environment variables
Copy `.env.example` to a file named `.env`, in your root application directory and populate the
variables according to the instructions provided.

## Run the test suite
```sh
$ bundle exec rake
```

## Update player data
The data used for the player pool is sourced from the [CBS Sports API][].
To update this data (e.g. updates to player teams, news, injuries, etc.) run the
following rake task:

```sh
$ rake players:update
```

[CBS Sports API]: http://developer.cbssports.com/documentation/files/draft-config
