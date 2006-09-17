package Facebook;

use warnings;
use strict;

use URI;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use XML::Simple;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = '0.0.0alpha1';

my $webbrowser = 'browser';

=begin html

<style>
a:visited { color: blue; }
a { text-decoration: none; }
a:hover { text-decoration: underline; }
body { margin: 2em; padding: 2em; background-color: white; }
html { background-color: lightblue; }
h1 { color: green; }
</style>

=end html

=head1 DOWNLOAD

L<http://oss.snoyman.com/Facebook-0.0.0alpha1.tar.gz>

=head1 DESCRIPTION

A simplistic library for accessing Facebook's API L<http://api.facebook.com>. It will pass messages from your program (either desktop or web based) to the Facebook REST server. Please read L</INFORMATION> below for more details, especially if writing a desktop version.

=head1 SYNOPSIS

use Facebook;
use CGI;

my $api_key = 'thisisprovidedbyfacebook';
my $secret  = 'soisthis';

my $cgi = CGI->new;
my $f = Facebook->new($api_key, $secret);

my $session = $cgi->param('session'); # Set in a previous request
my $auth_token = $cgi->param('auth_token'); # Same

if(!(defined $session) && !(defined $auth_token)) {
	print $cgi->redirect('http://api.facebook.com/login.php?api_key=' . $api_key);
	exit;
}
elsif(defined $auth_token) {
	$f->auth_token($auth_token);
	if($f->{SESSION}) {
		print $cgi->redirect('?session=' . $f->{SESSION});
	}
	else {
		print $cgi->redirect('?'); # Start over, something didn't work
	}
	exit;
}

=cut

=head1 CONSTRUCTORS

=head2 new($api_key, $secret)

=cut

sub new {
	my $class = shift;
	my ($api_key, $secret) = @_;

	my $browser = LWP::UserAgent->new;
	$browser->agent('Mozilla/9.0');
	my $self = {
		SERVERADDR => 'http://api.facebook.com/restserver.php',
		APIKEY     => $api_key,
		SECRET     => $secret,
		BROWSER    => $browser,
		XML        => XML::Simple->new,
	};

	bless $self, $class;
	return $self;
}

=head1 METHODS

=head2 login()

=cut

sub login {
	my $self = shift;
	print "Press enter after login is complete...";
	my $auth_token = $self->login_part1;
	<STDIN>;
	$self->auth_token($auth_token);
}

sub login_part1 {
	my ($self, $email, $password) = @_;
	my $auth_token = $self->call_method('facebook.auth.createToken')->{token};
	system "$webbrowser 'https://api.facebook.com/login.php?auth_token=$auth_token&api_key=$self->{APIKEY}'";
	return $auth_token;
}

=head2 auth_token($auth_token)

Given an auth_token that has already undergone login,
grab the secret, session, and uid via a
facebook.auth.getSession call.

=cut
sub auth_token {
	my $self = shift;
	my $auth_token = shift;
	
	my $xml = $self->call_method('facebook.auth.getSession', auth_token => $auth_token);
	my $secret = $xml->{secret};
	$self->{SECRET} = $secret if $secret;
	$self->{SESSION} = $xml->{session_key};
	$self->{UID}     = $xml->{uid};
	return $xml;
}

=head2 call_method($method, $param1key => $param1value, ...)

=cut

sub call_method {
	# This is ripped off of the java FacebookRestClient.callMethod
	my $self = shift;
	my $method = shift;
	my %params = @_;
	$params{method} = $method;
	$params{api_key} = $self->{APIKEY};
	$params{call_id} = time;
	if(my $session = $self->{SESSION}) {
		$params{session_key} = $session;
	}
	$params{sig} = $self->generate_sig(%params);
	
	my $browser = $self->{BROWSER};
	my $response = $browser->post($self->{SERVERADDR}, \%params);
	unless($response->is_success) {
		$self->{RESPONSE} = $response;
		return undef;
	}
	return $self->{XML}->XMLin($response->content);
}

=head2 generate_sig(@params)

Code based on java's FacebookRestClient.generateSig

=cut

sub generate_sig {
	my $self = shift;
	my @params;
	my %params = @_;
	while(@_) {
		my $key = shift;
		my $value = shift;
		push @params, "$key=$value";
	}
	return md5_hex(join('', sort @params) . $self->{SECRET});
}

1;

=head1 INFORMATION

Due to Facebook's anti-phishing approach, you need to allow the user to log in through their web browser. When writing a web app, this is easily handled (see the synopsis above). For a desktop application, this is more tricky. You'll need to manually edit the $browser variable in Facebook.pm to be the web browser (ie, /usr/bin/firefox). If you have any ideas on how to do this better, let me know.

This library will store all the information it needs to send requests, such as session. Once again, please read the L</SYNOPSIS>.

=cut
