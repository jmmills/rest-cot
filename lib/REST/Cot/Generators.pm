use 5.16.0;
use strict;
use warnings;

package REST::Cot::Generators;
use namespace::clean;
use Carp qw[croak];

sub progenitor {
    my $new = shift;
    return sub {
        state $ancestor;

        return $ancestor
            if $ancestor;

        $ancestor = $ancestor->{parent}->()
            while( ref $ancestor->{parent} eq 'CODE');

        return $ancestor;
    };
}

sub path {
    my $new = shift;
    return sub {
        state $path;
        return undef unless ref($new->{progenitor}->());
        return $path if $path;

        $path = @{ $new->{args} }?
        join ( '/', $new->{parent}
                        ->()
                        ->{path}
                        ->(),
                    @{ $new->{args} },
                    $new->{name}
        ) :
        join ( '/', $new->{parent}
                        ->()
                        ->{path}
                        ->(),
                        $new->{name}
        );

        return $path;
    };
}

sub client {
    my $new = shift;
    return sub {
        state $c;
        return $c if ref($c);

        my $is_valid = sub {
        my $client = shift;
        my @methods = qw[GET PUT PATCH POST DELETE OPTIONS HEAD];
        my $implements = scalar( grep { $client->can($_) } @methods );
        return ref($client) && $implements == scalar(@methods);
        };

        $c = $new->{progenitor}->()->{client};
        croak "$c does not provide an acceptable client interface"
        unless $is_valid->($c);

        return $c
    };
}

sub method {
    my $new = shift;
    return sub {
        my $method = shift;
        $new->{client}->$method( $new->{path}->(), @_ );
    }
}

no namespace::clean;
1;

