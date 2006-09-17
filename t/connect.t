#!/usr/bin/perl -I../lib -w

use Test::More tests => 4;
use Facebook;

use Data::Dumper;

my $api_key = '7fee505ff69ff67a0d02ec8ac0a06a3c';
my $secret = '13ddf47bf68e2de3a2396860ef60a49c';

my $f = Facebook->new($api_key, $secret);
ok($f->isa('Facebook'), 'new');

my $xml = $f->call_method('facebook.auth.createToken');
is($xml->{method}, 'facebook.auth.createToken', 'call_method returns correct method');

$f->login;
ok($f->{SECRET} && $f->{SECRET} ne $secret, 'login');

$xml = $f->call_method('facebook.messages.getCount');
is($xml->{unread}, 0, 'method call after login');

#$xml = $f->call_method('facebook.users.getInfo', users => $f->{UID}, fields => 'birthday');
