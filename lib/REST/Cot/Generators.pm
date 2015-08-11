use 5.16.0;
use strict;
use warnings;

package REST::Cot::Generators;
use namespace::clean;
use Carp qw[croak];

sub progenitor {
    my $self = shift;
    return sub {
        return $self unless $self->{parent};
        return $self->{parent}->{progenitor}->();
    };
}

sub path {
    my $self = shift;
    return sub {
        state $path;
        return undef unless ref($self->{progenitor}->());
        return $path if $path;

        $path = @{ $self->{args} }?
        join ( '/', $self->{parent}
                        ->{path}
                        ->(),
                    @{ $self->{args} },
                    $self->{name}
        ) :
        join ( '/', $self->{parent}
                        ->{path}
                        ->(),
                        $self->{name}
        );

        return $path;
    };
}

# TODO: make this inflate to something?
sub method {
    my $self = shift;
    return sub {
        my $method = shift;
        my $self = shift;
        return $self->{client}->$method( "$self", @_? \@_ : undef )
    }
}

no namespace::clean;
1;

