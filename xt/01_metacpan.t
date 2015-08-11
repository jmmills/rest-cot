use strict;
use warnings;
use Test::More;

use_ok 'REST::Cot';
my $metacpan = REST::Cot->new('http://api.metacpan.org/');

isa_ok $metacpan, 'REST::Cot::Fragment';
can_ok $metacpan, qw[GET POST PUT PATCH DELETE OPTIONS HEAD];

my $r = $metacpan->v0->author->JMMILLS->GET();
ok $r;

done_testing;