#!/usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;

require './unified/unified.pl';

&ReadParse();
&foreign_require("virtual-server", "virtual-server-lib.pl");
%vserver_lang = load_language('virtual-server');

if (true) {
	# Get and sort the domains
	@alldoms = &virtual_server::list_domains();
	@doms = &virtual_server::list_visible_domains();

	# Work out which domain we are editing
	if (defined($in{'dom'})) {
		$d = &virtual_server::get_domain($in{'dom'});
	}
	elsif (defined($in{'dname'})) {
		$d = &virtual_server::get_domain_by("dom", $in{'dname'});
		if (!$d) {
			# Couldn't find domain by name, search by user instead
			$d = &virtual_server::get_domain_by(
				"user", $in{'dname'}, "parent", "");
		}
	}
	elsif ($sects && $sects->{'dom'}) {
		$d = &virtual_server::get_domain($sects->{'dom'});
		$d = undef if (!&virtual_server::can_edit_domain($d));
	}

	# Make sure the selected domain is in the menu .. may not be for
	# alias domains if they are hidden
	if ($d && &virtual_server::can_edit_domain($d)) {
		my @ids = map { $_->{'id'} } @doms;
		if (&indexof($d->{'id'}, @ids) < 0) {
			push(@doms, $d);
		}
	}
	@doms = &virtual_server::sort_indent_domains(\@doms);

	# Fall back to first owned by this user, or first in list
	$d ||= &virtual_server::get_domain_by("user", $remote_user, "parent", "");
	$d ||= $doms[0];
} else {
	$d = { 'id' => $in{'dom'} };
}
$did = $d ? $d->{'id'} : undef;

$doms.= &list_virtualmin_domains();

#&header();
print "Content-Security-Policy: script-src 'self' 'unsafe-inline'; frame-src 'self'\n";
print "Content-type: text/html; Charset=utf-8\n\n";
print $doms;