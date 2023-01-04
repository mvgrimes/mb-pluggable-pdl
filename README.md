# NAME

Module::Build::Pluggable::PDL - Plugin to Module::Build to build PDL projects

# VERSION

version 0.22

# SYNOPSIS

    # Build.PL
    use strict;
    use warnings;
    use Module::Build::Pluggable ('PDL');

    my $builder = Module::Build::Pluggable->new(
        dist_name  => 'PDL::My::Module',
        license    => 'perl',
        requires   => { },
    );
    $builder->create_build_script();

# DESCRIPTION

This is a plugin for [Module::Build](http://search.cpan.org/perldoc?Module::Build) (using [Module::Build::Pluggable](http://search.cpan.org/perldoc?Module::Build::Pluggable))
that will assist in building [PDL](http://search.cpan.org/perldoc?PDL) distributions. Please see the
[Module::Build::Authoring](http://search.cpan.org/perldoc?Module::Build::Authoring) documentation if you are not familiar with it.

- Add Prerequisites

        requires => { 'PDL' => '2.000' },
        build_requires => {
            'PDL'                => '2.000',
            'ExtUtils::CBuilder' => '0.23',
        },

    You can, or course, require your own versions of these modules by adding them
    to `requires =` {}> as usual. 

- Process `.pd` files

    The `lib` directory of your distribution will be searched for `.pd` files
    and, immediately prior to the build phase, these will be processed by
    `PDL::PP` into `.xs` and `.pm`. files as required to continue the build
    process.  These will then be processed by `Ext::CBuilder` as normal. These
    files are also added to the list of file to be cleaned up.

    In addition, an entry will be made into `provides` for the `.pm` file of the
    `META.json/yml` files. This will assist PAUSE, search.cpan.org and metacpan.org
    in properly indexing the distribution and 

- Generate `.pod` file from the `.pd`

    When building the distribution (`./Build dist` or `./Build distdir`), any
    `.pd` file found in the `lib` directory will converted into `.pod` files.
    This produces a standalone version of the documentation which can be viewed
    on search.cpan.org, metacpan.org, etc. When these sites attempt to display 
    the pod in the `.pd` files directly, there is often formatting and processing
    issues.

    This is accomplished by first processing the files with `PDL::PP` and then
    `perldoc -u`.

- Add Include Dirs

        include_dirs => PDL::Core::Dev::whereami_any() . '/Core';

    The `PDL/Core` directory is added to the `include_dirs` flag.

- Add Extra Linker Flags

        extra_linker_flags =>  $PDL::Config{MALLOCDBG}->{libs}
          if $PDL::Config{MALLOCDBG}->{libs};

    If needed, the MALLOCDBG libs will be added to the `extra_linker_flags`.

# SEE ALSO

This is essentially a rewrite of David Mertens' [Module::Build::PDL](http://search.cpan.org/perldoc?Module::Build::PDL) to use
[Module::Build::Pluggable](http://search.cpan.org/perldoc?Module::Build::Pluggable). The conversion to [Module::Build::Pluggable](http://search.cpan.org/perldoc?Module::Build::Pluggable)
fixes multiple inheritance issues with subclassing [Module::Build](http://search.cpan.org/perldoc?Module::Build). In
particular, I needed to be able use the [Module::Build::Pluggable::Fortran](http://search.cpan.org/perldoc?Module::Build::Pluggable::Fortran)
in my PDL projects.

Thank you David++ for [Module::Build::PDL](http://search.cpan.org/perldoc?Module::Build::PDL).

Of course, all of this just tweaks the [Module::Build](http://search.cpan.org/perldoc?Module::Build) setup.

# AUTHOR

Mark Grimes, <mgrimes@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Mark Grimes, <mgrimes@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
