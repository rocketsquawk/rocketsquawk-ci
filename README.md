RocketSquawk CI
===============

RocketSquawk CI provides a fully-functional Continuous Integration / Continuous
Delivery toolchain packaged as a stand-alone [Vagrant][1] virtual machine. The
project uses [Veewee][2] to build and configure a [Vagrant][1] box based on Debian
Wheezy (7.0), JetBrains TeamCity, GitLab, Chef, and JFrog Artifactory.

Installation
------------

### As a submodule

From the root of your cloned veewee repository:

```bash
$ git submodule add -f https://github.com/rocketsquawk/rocketsquawk-ci.git definitions/rocketsquawk-ci
```

NOTE: The `-f` switch is required because the veewee project's .gitignore file contains the rule `definitions/*`. If you don't force the `submodule add` operation, you'll get:

	The following path is ignored by one of your .gitignore files:
	definitions/rocketsquawk-ci
	Use -f if you really want to add it.

### The kludgy way

If you don't want to mess with submodules, this way is for you. Make sure you have [Vagrant][1] and [Veewee][2] installed and functioning.

Clone the rocketsquawk-ci repository:

```bash
$ git clone https://github.com/rocketsquawk/rocketsquawk-ci.git
```

Create a `definitions/rocketsquawk-ci` directory in your cloned veewee repository, and copy the RocketSquawk CI file to it:

```bash
$ mkdir <your_cloned_veewee_repo>/definitions/rocketsquawk-ci
$ cp rocketsquawk-ci/* <your_cloned_veewee_repo>/definitions/rocketsquawk-ci/
```
    
So, for example (this is how *my* filesystem is laid out; *yours* is different):

```bash
$ mkdir ~/Development/veewee/definitions/rocketsquawk-ci
$ cp rocketsquawk-ci/* ~/Development/veewee/definitions/rocketsquawk-ci/
```

Building
--------

In your cloned veewee repository:

```bash
$ veewee vbox build 'rocketsquawk-ci' --workdir=<your_cloned_veewee_repo>
```

So, for me:

```bash
$ veewee vbox build 'rocketsquawk-ci' --workdir=~/Development/veewee
```

Using
-----

Export to a `rocketsquawk-ci.box` file:

```bash
$ veewee vbox export 'rocketsquawk-ci'
```

Add the box to Vagrant:

```bash
$ vagrant box add 'rocketsquawk-ci-x86' 'rocketsquawk-ci.box'
````

Use the box:

```bash
$ vagrant init 'rocketsquawk-ci-x86'
$ vagrant up
$ vagrant ssh
```

TODO
----

* Post-"installation" instructions: how to start services, etc.

[1]: http://vagrantup.com "Vagrant"
[2]: https://github.com/jedi4ever/veewee "Veewee"
