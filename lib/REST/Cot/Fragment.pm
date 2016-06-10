package REST::Cot::Fragment;

use 5.16.0;
use strict;
use warnings;

# TODO: trace interface topology for SPORE spec?
# TODO: trace interface topology for Swagger spec?

use namespace::autoclean;
use Hash::Merge::Simple 'merge';
use REST::Cot::Generators;
use overload
  '""' => sub { 
            my $self = shift;
            return $self->{uri}
                        ->()
                        ->as_string()
            if ref($self->{uri}) eq 'CODE';

            return $self->{path}->();
          },
  '~' => sub { shift->{progenitor}->() },
  'fallback' => 1;

our $AUTOLOAD;

sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self) 
    or return;
  my @args = @_;
  my $fragment = $AUTOLOAD;

  $fragment =~ s/.*:://;

#  DISABLE fragment caching, this is slower but the interface works correctly  
#  return $self->{fragments}->{$fragment}->()
#    if exists $self->{fragments}->{$fragment};

  my $sub = sub {
    my $new = bless({}, __PACKAGE__);

    $new->{parent} = $self;
    $new->{name} = $fragment;
    $new->{query} = {};
    $new->{client} = $self->{client};

    $new->{args} = [grep { !ref($_) } @args];
    $new->{query} = merge(grep { ref($_) eq 'HASH'} @args) || {};

    $new->{progenitor}   = REST::Cot::Generators::progenitor($new);
    $new->{uri}          = REST::Cot::Generators::uri($new);
    $new->{path}         = REST::Cot::Generators::path($new);
    $new->{method}       = REST::Cot::Generators::method($new);
    $new->{merged_query} = REST::Cot::Generators::merged_query($new);

    return $new;
  };

  return ($self->{fragments}->{$fragment} = $sub)->();
}

sub DESTROY {
  # We don't want this being called via autoload since an object is out of scope by this point
}

sub GET     { shift->{method}->( 'GET', @_ ); }
sub PUT     { shift->{method}->( 'PUT', @_ ); }
sub PATCH   { shift->{method}->( 'PATCH', @_ ); }
sub POST    { shift->{method}->( 'POST', @_ ); }
sub DELETE  { shift->{method}->( 'DELETE', @_ ); }
sub OPTIONS { shift->{method}->( 'OPTIONS', @_ ); }
sub HEAD    { shift->{method}->( 'HEAD', @_ ); }

1;

