package Facebook::Cookie;
BEGIN {
  $Facebook::Cookie::VERSION = '0.006';
}
# ABSTRACT: Analyzed and signed Facebook Cookie reflection

use Moose;
use Digest::MD5 qw/md5_hex/;
use Carp qw/croak/;
use namespace::autoclean;


has cookie => (
	isa => 'Maybe[Str]',
	is => 'ro',
	lazy => 1,
	default => sub {
		my ( $self ) = @_;
		return join('&',$self->catalyst_request->cookie('fbs_'.$self->app_id)->value)
			if $self->catalyst_request->cookie('fbs_'.$self->app_id);
	},
);


has catalyst_request => (
	isa => 'Catalyst::Request',
	is => 'ro',
	lazy => 1,
	default => sub { croak "catalyst_request required" },
);


has secret => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub { croak "secret required" },
);


has app_id => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub { croak "app_id required" },
);

has _signed_values => (
	isa => 'HashRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my ( $self ) = @_;
		check_payload($self->cookie, $self->secret);
	},
);


sub check_payload {
	my ( $cookie, $app_secret ) = @_;

	return {} if !$cookie;
	
	$cookie =~ s/^"|"$//g;

	my $hash;
	my $payload;

	map {
		my ($k,$v) = split '=', $_;
		$hash->{$k} = $v;
		$payload .= $k .'='. $v if $k ne 'sig';
	} split('&',$cookie);
	
	if (md5_hex($payload.$app_secret) eq $hash->{sig}) {
		return $hash;
	}
	
	return {};
}


sub uid {
	my ( $self ) = @_;
	return $self->_signed_values->{uid};
}


sub access_token {
	my ( $self ) = @_;
	return $self->_signed_values->{access_token};
}


sub session_key {
	my ( $self ) = @_;
	return $self->_signed_values->{session_key};
}


sub expires {
	my ( $self ) = @_;
	return $self->_signed_values->{expires};
}


sub base_domain {
	my ( $self ) = @_;
	return $self->_signed_values->{base_domain};
}

1;
__END__
=pod

=head1 NAME

Facebook::Cookie - Analyzed and signed Facebook Cookie reflection

=head1 VERSION

version 0.006

=head1 SYNOPSIS

  my $fb_cookie = Facebook::Cookie->new(
    cookie => $cookie,
	secret => $secret,
  );

  my $fb_cookie = Facebook::Cookie->new(
    catalyst_request => $c->req,
	app_id => $app_id,
	secret => $secret,
  );
  
  my $fb_uid = $fb_cookie->uid;
  my $fb_access_token = $fb_cookie->access_token;
  my $fb_session_key = $fb_cookie->session_key;

=head1 DESCRIPTION

If you have any suggestion how we can use this package namespace, please suggest to authors listed in the end of this document.

=head1 METHODS

=head2 cookie

Is a: String

This cookie is used for checking the data, if its not there you must give catalyst_request and app_id, so that it can
be taken from there.

=head2 catalyst_request

Is a: Catalyst::Request

If there is no cookie given, this is used in combination with app_id

=head2 secret

Is a: String

This is the secret for your application, its required for nearly all features of this framework.

=head2 app_id

Is a: String

This is the application id, also required for nearly all features of this framework.

=head2 Facebook::Cookie::check_payload

Arguments: $cookie, $app_secret

Return value: HashRef

Checks the signature of the given cookie (as text) with the given application secret and gives back the checked HashRef or 
an empty one.

=head2 $obj->uid

Arguments: None

Return value: Integer

Gives back the signed uid of the cookie given

=head2 $obj->access_token

Arguments: None

Return value: String

Gives back the signed access_token of the cookie given

=head2 $obj->session_key

Arguments: None

Return value: String

Gives back the signed session_key of the cookie given

=head2 $obj->expires

Arguments: None

Return value: Integer

Gives back the signed expire date as timestamp of the cookie given

=head2 $obj->base_domain

Arguments: None

Return value: String

Gives back the signed base_domain of the cookie given

=encoding utf8

=head1 ATTRIBUTES

=head1 METHODS

=head1 AUTHOR

Torsten Raudssus <torsten@raudssus.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Facebook Distribution Authors.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

