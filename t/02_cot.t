use strict;
use warnings;
use Test::More;

use_ok 'REST::Cot';
my $cot = REST::Cot->new('http://localhost');

isa_ok $cot, 'REST::Cot::Fragment'
    or diag ref($cot);
can_ok $cot, qw[GET POST PUT PATCH DELETE OPTIONS HEAD];
isa_ok $cot->{client}, 'REST::Client';

my $d = $cot->a->b->c->d;
is "$d", '/a/b/c/d';
is ~$d, '/a';

done_testing;