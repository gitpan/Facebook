#!/usr/bin/perl -w -I../lib

push @INC, '../lib';

use Test::More tests => 4;
use Facebook;

my $f = Facebook->new('api', 'secret');
ok($f->isa('Facebook'), 'new');

is($f->{SECRET}, 'secret', 'secret');
is($f->{APIKEY}, 'api', 'apikey');

my @params = (session_key => 'session', method => 'method', call_id => '5000', api_key => 'api');
is(
	$f->generate_sig(@params),
	'3aca9b35e82437f3e0b787a0f82f6cfb',
	'generate_sig'
);
