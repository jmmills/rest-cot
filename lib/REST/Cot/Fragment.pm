use 5.16.0;
use strict;
use warnings;

# TODO: add some response inflator
# TODO: trace interface topology for SPORE spec?
# TODO: trace interface topology for Swagger spec?

package REST::Cot::Fragment;
use REST::Cot::Generators;

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

    $new->{progenitor} = REST::Cot::Generators::progenitor($new);
    $new->{path}       = REST::Cot::Generators::path($new);
    $new->{client}     = REST::Cot::Generators::client($new);
    $new->{method}     = REST::Cot::Generators::method($new);

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

