package REST::Cot;

use 5.16.0;
use strict;
use warnings;

# ABSTRACT: REST easier, lay on a cot

=head1 SYNOPSIS

This package is a blatant rip-off of Python's Hammock library. 

  my $metacpan = REST::Cot->new('http://api.metacpan.org/');
  my $data = $metacpan->v0->author->JMMILLS->GET();

  say $data->{email}->[0]; # jmmills@cpan.org

=head1 CAVEAT

This package was developed for an application I maintain as conviencince. It's under-documented, and under-tested.
YMMV

=cut

use URI;
use REST::Client;
use REST::Cot::Fragment;

sub new {
    my $class = shift;
    my $host  = shift;

    my $ref = {};
    $ref->{parent} = undef;
    $ref->{client} = REST::Client->new({host => $host, @_});
    $ref->{root} = 1;
    $ref->{path} = sub { '' };

    bless($ref, 'REST::Cot::Fragment');

    return $ref;
}

1;
__END__;
