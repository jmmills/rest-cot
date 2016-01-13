use strict;
use warnings;
use REST::Client;
use Test::More;

require_ok 'REST::Cot::Fragment';

my $obj = bless({
    parent => undef,
    client => REST::Client->new({host => 'http://example.com'}),
    path => sub { '' }
}, 'REST::Cot::Fragment');

isa_ok $obj, 'REST::Cot::Fragment'
  or diag $obj;

can_ok $obj, $_ for qw[GET PUT PATCH POST DELETE OPTIONS HEAD];

isa_ok $obj->foo, 'REST::Cot::Fragment';

is $obj->foo->{path}->(), '/foo';

is $obj->foo->bar->{path}->(), '/foo/bar';

is $obj->stuff(qw[a b])->{path}->(), '/stuff/a/b';

done_testing();
