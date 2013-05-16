package Module::Build::Pluggable::PDL;

use strict;
use warnings;
our $VERSION = '1.00';
use parent qw(Module::Build::Pluggable::Base);

use PDL::Core::Dev;
use List::MoreUtils qw(first_index);

sub HOOK_build {
    my ($self) = @_;

    $self->add_before_action_modifier( 'dist', \&HOOK_distdir );
    $self->add_before_action_modifier( 'dist', \&HOOK_distdir );
    $self->add_action( 'forcepdlpp', \&ACTION_forcepdlpp );

    return 1;
}

sub HOOK_configure {
    my ($self) = @_;

    $self->_insert_build_element_before( 'pd', 'pm' );

    $self->_add_include_dirs( PDL::Core::Dev::whereami_any() . '/Core' );

    $self->builder->add_extra_linker_flags( $PDL::Config{MALLOCDBG}->{libs} )
      if $PDL::Config{MALLOCDBG}->{libs};

    $self->configure_requires( 'PDL', => '2.006' );
    $self->build_requires( 'PDL', => '2.006' );

    return 1;
}

sub _insert_build_element_before {
    my ( $self, $new_element, $before ) = @_;

    my $build_elements = $self->builder->build_elements;
    my $xs_index = first_index( sub { $_ eq $before }, @$build_elements ) || 0;
    splice @$build_elements, $xs_index - 1, 0, 'pd';
    $self->builder->build_elements($build_elements);

    {
        no strict 'refs';
        *{ ref( $self->builder ) . '::process_pd_files' } = \&process_pd_files;
    }
}

sub _add_include_dirs {
    my ( $self, @dirs ) = @_;

    my $include_dirs = $self->builder->include_dirs;
    push @$include_dirs, @dirs;
    $self->builder->include_dirs($include_dirs);
}

# Allow the person installing to force a PDL::PP rebuild
sub ACTION_forcepdlpp {
    my $self = shift;
    $self->log_info("Forcing PDL::PP build\n");
    $self->{FORCE_PDL_PP_BUILD} = 1;
    $self->ACTION_build();
}

# largely based on process_PL_files and process_xs_files in M::B::Base
sub process_pd_files {
    my $self = shift;

    # Get all the .pd files in lib
    my $files = $self->rscan_dir( 'lib', qr/\.pd$/ );

    # process each in turn
    for my $file (@$files) {

        # Based heavily on process_xs

        # Remove the .pd extension to get the build file prefix, which
        # says where the .xs and .pm files should be placed when we run
        # PDL::PP on the .pd file
        ( my $build_prefix = $file ) =~ s/\.[^.]+$//;

        # Figure out the file's lib-less prefix, which tells perl where it
        # will be installed _within_ lib:

        ( my $prefix = $build_prefix ) =~ s|.*lib/||;

        # Build the module name (Surely there's a M::B function for this?)
        ( my $mod_name = $prefix ) =~ s|/|::|g;

        # see sub run_perl_command (yet undocumented)
        # PDL::PP's import argument are, in order:
        # Module name -> for example, PDL::Graphics::PLplot
        # Package name -> used in package line of the .pm file; for our purposes,
        #     this is identical to Module name.
        # Prefix -> the extensionless file name, PDL/Graphics/PLplot
        #    .pm and .xs extensions will be added to this when the files are
        #    produced, so this should include a lib/ prefix
        # Callpack -> an optional argument used for the XS PACKAGE keyword;
        #    if left blank, it will be identical to the module name
        my $PDL_arg = "-MPDL::PP qw[$mod_name $mod_name $build_prefix]";

        # Both $self->up_to_date and $self->run_perl_command are undocumented
        # so they could change in the future:
        my $up_to_date = $self->up_to_date( $file,
            [ "$build_prefix.pm", "$build_prefix.xs" ] );
        if ( $self->{FORCE_PDL_PP_BUILD} or not $up_to_date ) {
            $self->run_perl_command( [ $PDL_arg, $file ] );
        }

        warn "provides....$file\n";
        $self->meta_merge(
            'provides',
            {
                $mod_name => { file => $file, version => $self->dist_version },
            } );

        $self->add_to_cleanup( "$build_prefix.pm", "$build_prefix.xs" );

        # Add the newly created .pm and .xs files to the list of such files?
        # No, because the current build process looks for all such files and
        # processes them, and it doesn't create that list until it's actually
        # processing the .pm and .xs files.
    }
}

sub HOOK_distdir {
    my ($self) = @_;

    warn "###  Hi there!\n";

    # my $files = $self->rscan_dir( 'lib', qr/\.pd$/ );
    # use DDP; p $files;

    # for my $file (@$files) {
    #     ( my $build_prefix = $file ) =~ s{\.pd$}{};
    #     ( my $prefix       = $build_prefix ) =~ s{/?lib/}{};
    #     ( my $package      = $build_prefix ) =~ s{/}{::}g;

    #     # perl -MPDL::PP=PDL::Opt::QP,PDL::Opt::QP,lib/PDL/Opt/QP lib/PDL/Opt/QP.pd
    #     # && perldoc -u lib/PDL/Opt/QP.pm > lib/PDL/Opt/QP.pod
    #     $self->do_system(
    #         "perl -MPDL::PP=$package,$package,$build_prefix $file && perldoc -u $build_prefix.pm > $build_prefix.pod"
    #     );
    #     $self->add_to_cleanup("$build_prefix.pod");
    # }

    return 1;
}

1;
