package REST::Cot::Generators;

use 5.16.0;
use strict;
use warnings;
use Email::MIME::ContentType;
use URI;
use JSON;
use Carp qw[confess];
use Hash::Merge::Simple 'merge';
use namespace::autoclean;

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
          join ( '/', $self->{parent}->{path}->(), $self->{name}, @{ $self->{args} } ) :
          join ( '/', $self->{parent}->{path}->(), $self->{name} );

        return $path;
    };
}

sub merged_query {
  my $self = shift;

  return sub {
      if ($self->{parent}->{merged_query}) {
          return merge($self->{query}, $self->{parent}->{merged_query}->());
      } else {
          return $self->{query};
      }
  };
}

sub uri {
  my $self = shift;

  return sub {
      my $path = $self->{path}->();
      my $q = $self->{merged_query}->();
      my $uri = URI->new($path);

      $uri->query_form($q);

      return $uri
  };
}

sub method {
    my $self = shift;
    return sub {
        my $method = shift;
        my $self = shift;

        my $response = $self->{client}->$method( "$self", @_ );

        if (my $content_type = $response->responseHeader('Content-Type')) {
          $content_type = parse_content_type($content_type);
          my $body = $response->responseContent;
          my $code = $response->responseCode;
          my $type = $content_type->{type};
          my $subtype = $content_type->{subtype};

          if ($type eq 'application') {
            my $decoded = $body;

            $decoded = from_json($body)
              if ($subtype eq 'json');

            $decoded = $response->responseXpath
              if ($subtype eq 'xml'); 

            return !wantarray? $decoded : ($decoded, $code, $response);
          } else {
              return $response;
          }
        } else {
          return $response;
        }
    }
}

no namespace::clean;
1;

