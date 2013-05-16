use strict;
use warnings;
use Test::More;
use Path::Class;
use List::MoreUtils qw(any);
use IPC::Cmd qw(run);

BEGIN {
    my $var = dir('t/var');
    $var->rmtree;
    $var->mkpath;
    chdir $var;
    file('MANIFEST')->spew('');
    dir('lib/PDL/Test')->mkpath;
    file('lib/PDL/Test/PD.pd')->spew(<<'PDFILE');
pp_setversion($VERSION);
pp_addpm({At=>'Top'},<<'EOD');
use strict;
use warnings;

=head1 NAME

PDL::Test::PD - Test PD File
# ABSTRACT: Test PD File

=head1 SYNOPSIS

 use PDL::Test::PD;
 ...

=head1 DESCRIPTION

...

=cut

EOD
pp_done();  # you will need this to finish pp processing
PDFILE
}

use Module::Build::Pluggable ('PDL');

my $builder = Module::Build::Pluggable->new(
    dist_name      => 'Eg',
    dist_version   => 0.01,
    dist_abstract  => 'test',
    dynamic_config => 0,
    module_name    => 'Eg',
    requires       => {},
    provides       => {},
    author         => 1,
    dist_author    => 'test',
);
$builder->create_build_script();
is( @{ $builder->include_dirs }, 1, "added include dirs" );
ok( any( sub { $_ eq 'pd' }, @{ $builder->build_elements } ),
    "added pd to build elements" );

ok( -f 'Build', 'Build file created' );

my $buffer;
ok( run( command => './Build', verbose => 1, buffer => \$buffer ), 'Ran Build' )
  or diag $buffer;

ok( -f 'lib/PDL/Test/PD.pm', '... Build created .pm file' );
ok( -f 'lib/PDL/Test/PD.xs', '... and .xs file' );

ok( run( command => './Build distmeta', verbose => 1, buffer => \$buffer ),
    "Ran Build distmeta" );
ok( -f 'META.json', 'Build created META.json file' );

ok( run( command => './Build distdir', verbose => 1, buffer => \$buffer ),
    "Ran Build distdir" );
ok( -f 'lib/PDL/Test/PD.pod', '... and .pod file' );

# ok( run( command=>'./Build clean', verbose=>1, buffer=>\$buffer ), "Ran Build clean");
# ok(! -f 'lib/PDL/Test/PD.pm', 'Build clean removed .pm file' );
# ok(! -f 'lib/PDL/Test/PD.xs', '... and .xs file' );
# ok(! -f 'lib/PDL/Test/PD.pod', '... and .pod file' );

done_testing;
