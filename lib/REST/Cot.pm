use 5.16.0;
use strict;
use warnings;
package REST::Cot;

# ABSTRACT: REST easier, pythons hammock for perl

use REST::Client;
use REST::Cot::Fragment;

sub new {
    my $class = shift;
    my $host  = shift;

    my $ref = {};
    $ref->{parent} = undef;
    $ref->{client} = REST::Client->new({host => $host, @_});
    $ref->{path} = sub { '' };
    bless($ref, 'REST::Cot::Fragment');

    return $ref;
}

1;
__END__;
