# NAME

Module::Build::Pluggable::PDL - Plugin to Module::Build to process PDL's .pd files

# VERSION

version 0.20

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
that will assist in building [PDL](http://search.cpan.org/perldoc?PDL) distributions.

- Add Include Dirs

        include_dirs => PDL::Core::Dev::whereami_any() . '/Core';
- Add Extra Linker Flags

        extra_linker_flags =>  $PDL::Config{MALLOCDBG}->{libs}
          if $PDL::Config{MALLOCDBG}->{libs};
- Add Prerequisites

        requires => { 'PDL' => '2.000' },
        build_requires => {
            'PDL'                => '2.000',
            'ExtUtils::CBuilder' => '0.23',
        },

    You can, or course, require your own versions of these modules by adding them
    to `requires =` {}> as usual. 

- Process `.pd` files

    The `lib` directory of your distribution will be searched for `.pd` files.
    Immediately prior to the build phase, these will be processed by `PDL::PP`
    into `.xs`, `.pm`, etc. files as required to continue the build process.
    These will then be processed by `Ext::CBuilder` as normal.

# SEE ALSO

[Module::Build::PDL](http://search.cpan.org/perldoc?Module::Build::PDL)
[Module::Build](http://search.cpan.org/perldoc?Module::Build)
[Module::Build::Pluggable](http://search.cpan.org/perldoc?Module::Build::Pluggable)

# AUTHOR

Mark Grimes, <mgrimes@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Mark Grimes, <mgrimes@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
