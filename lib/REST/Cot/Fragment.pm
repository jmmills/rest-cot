use 5.16.0;
use strict;
use warnings;

# TODO: add some response inflator
# TODO: trace interface topology for SPORE spec?

package REST::Cot::Fragment;
use Carp qw[croak];
use AutoLoader;

our $AUTOLOAD;

sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self) 
    or return;
  my @args = @_;
  my $fragment = $AUTOLOAD;

  $fragment =~ s/.*:://;

  return $self->{fragments}->{$fragment}->()
    if exists $self->{fragments}->{$fragment};

  my $sub = sub {
    my $new = bless({}, __PACKAGE__);

    $new->{parent} = sub { $self };
    $new->{name} = $fragment;
    $new->{args} = [@args];

    $new->{projenitor} = sub {
      state $ancestor;
      return $ancestor if $ancestor;

      $ancestor = $ancestor->{parent}->() 
        while( ref($ancestor->{parent}) eq 'CODE' );

      return $ancestor;
    };

    $new->{path} = sub { 
      state $path;
      return undef unless ref($new->{projenitor}->());
      return $path if $path;

      $DB::single=1;
      $path = @{ $new->{args} }?
        join ( '/', $new->{parent}->()->{path}->(), @{ $new->{args} }, $new->{name} ) :
        join ( '/', $new->{parent}->()->{path}->(), $new->{name} );

      return $path;
    };

    $new->{client} = sub {
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

    $new->{method} = sub {
      my $method = shift;
      $new->{client}->$method( $new->{path}->(), @_ );
    };

    return $new;
  };

  return ($self->{fragments}->{$fragment} = $sub)->();
}

sub GET     { shift->{method}->( (caller(0))[3], @_ ); }
sub PUT     { shift->{method}->( (caller(0))[3], @_ ); }
sub PATCH   { shift->{method}->( (caller(0))[3], @_ ); }
sub POST    { shift->{method}->( (caller(0))[3], @_ ); }
sub DELETE  { shift->{method}->( (caller(0))[3], @_ ); }
sub OPTIONS { shift->{method}->( (caller(0))[3], @_ ); }
sub HEAD    { shift->{method}->( (caller(0))[3], @_ ); }

1;

__END__;

