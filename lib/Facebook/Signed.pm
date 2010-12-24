package Facebook::Signed;
BEGIN {
  $Facebook::Signed::AUTHORITY = 'cpan:GETTY';
}
BEGIN {
  $Facebook::Signed::VERSION = '0.010';
}
# ABSTRACT: Signed values given by Facebook to an application

use Moose;
use Digest::MD5 qw/md5_hex/;
use Carp qw/croak/;
use namespace::autoclean;


has facebook_data => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);


has secret => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub { croak "secret required" },
);

has _signed_values => (
	isa => 'HashRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my ( $self ) = @_;
		check_payload($self->facebook_data, $self->secret);
	},
);


sub get {
	my ( $self, $key ) = @_;
	return $self->_signed_values->{$key};
}


sub check_payload {
	my ( $facebook_data, $app_secret ) = @_;

	return {} if !$facebook_data;

	my $hash;
	my $payload;

	map {
		# TODO: test what happens if you have a = in the values
		my ($k,$v) = split '=', $_;
		$hash->{$k} = $v;
		$payload .= $k .'='. $v if $k ne 'sig';
	} split('&',$facebook_data);
	
	if (md5_hex($payload.$app_secret) eq $hash->{sig}) {
		# TODO: fix html encoding?
		return $hash;
	}
	
	return {};
}


sub uid {
	my ( $self ) = @_;
	return $self->get('uid');
}


sub access_token {
	my ( $self ) = @_;
	return $self->get('access_token');
}


sub session_key {
	my ( $self ) = @_;
	return $self->get('session_key');
}


sub expires {
	my ( $self ) = @_;
	return $self->get('expires');
}


sub base_domain {
	my ( $self ) = @_;
	return $self->get('base_domain');
}

1;
__END__
=pod

=head1 NAME

Facebook::Signed - Signed values given by Facebook to an application

=head1 VERSION

version 0.010

=head1 SYNOPSIS

  my $signed = Facebook::Signed->new(
	facebook_data => $cookie_as_text,
	secret => $secret,
  );

  my $custom_value = $signed->get('custom_key');

  # shortcuts, return undef if not existing
  my $fb_uid = $signed->uid;
  my $fb_access_token = $signed->access_token;
  my $fb_session_key = $signed->session_key;

=head1 DESCRIPTION

If you have any suggestion how we can use this package namespace, please suggest to authors listed in the end of this document.

=head1 METHODS

=head2 facebook_data

Is a: String

This data is used for getting the signed values. Its required on construction.

=head2 secret

Is a: String

This is the secret for your application. Its required on construction.

=head2 $obj->get

Arguments: $key

Return value: Str

Returns the value of a specific key of the signed values or undef it this is not exist.

=head2 Facebook::Signed::check_payload

Arguments: $facebook_data, $app_secret

Return value: HashRef

Checks the signature of the given facebook data (from cookie or other ways) with the given application secret 
and gives back the checked HashRef or an empty one.

=head2 $obj->uid

Arguments: None

Return value: Integer

Gives back the signed uid of the signed values given

=head2 $obj->access_token

Arguments: None

Return value: String

Gives back the signed access_token of the signed values given

=head2 $obj->session_key

Arguments: None

Return value: String

Gives back the signed session_key of the signed values given

=head2 $obj->expires

Arguments: None

Return value: Integer

Gives back the signed expire date as timestamp of the signed values given

=head2 $obj->base_domain

Arguments: None

Return value: String

Gives back the signed base_domain of the cookie given

=encoding utf8

=head1 ATTRIBUTES

=head1 METHODS

=head1 AUTHOR

Torsten Raudssus <torsten@raudssus.de> L<http://www.raudssus.de/>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Raudssus Social Software & Facebook Distribution Authors.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

