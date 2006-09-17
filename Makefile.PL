use ExtUtils::MakeMaker;

my %prereqs = (
	URI => 0,
	Digest::MD5 => 0,
	LWP::UserAgent => 0,
	XML::Simple => 0,
	Data::Dumper => 0,
);

WriteMakefile(
	NAME          => 'Facebook',
	VERSION_FROM  => 'lib/Facebook.pm',
	DISTNAME      => 'Facebook',
	PREREQ_PM     => \%prereqs,
);
