#!/usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;

require './unified/unified.pl';

# Some vars initialisation
$hostname = &get_display_hostname();
$version = &get_webmin_version();
&get_miniserv_config(\%miniserv);

if ($gconfig{'real_os_type'}) {
	if ($gconfig{'os_version'} eq "*") {
		$ostr = $gconfig{'real_os_type'};
	} else {
		$ostr = "$gconfig{'real_os_type'} $gconfig{'real_os_version'}";
	}
} else {
    $ostr = "$gconfig{'os_type'} $gconfig{'os_version'}";
}

&ReadParse();

@visible_modules = &get_visible_module_infos();

%categories = &list_categories(\@visible_modules);
@categories = sort { $b cmp $a } keys %categories;

$gconfig{'sysinfo'} = 0 if ($gconfig{'sysinfo'} == 1);
$main::theme_index_page = 1;
$title = $gconfig{'nohostname'} ? $text{'main_title2'} : &text('main_title', $version, $hostname, $ostr);
&header($title, "", undef, undef, 1, 1);

local $os_type = $gconfig{'real_os_type'} ? $gconfig{'real_os_type'} : $gconfig{'os_type'};
local $os_version = $gconfig{'real_os_version'} ? $gconfig{'real_os_version'} : $gconfig{'os_version'};

$header = '';

if ($charset) {
    $header .= "<meta http-equiv=\"Content-Type\" ", "content=\"text/html; Charset=$charset\">\n";
}
$header .= "<link rel='icon' href='$gconfig{'webprefix'}/images/webmin_icon.png' type='image/png'>\n";

if (@_ > 0) {
    local $title = &get_html_title($_[0]);
    $header .= "<title>$title</title>\n";
    $header .= $_[7] if ($_[7]);
    if ($gconfig{'sysinfo'} == 0 && $remote_user) {
    	$header .= &get_html_status_line(0);
    }
}

if ($remote_user && @_ > 1) {
    local $logout = $main::session_id ? "/session_login.cgi?logout=1" : "/switch_user.cgi";
    local $loicon = $main::session_id ? "logout.jpg" : "switch.jpg";
    local $lowidth = $main::session_id ? 84 : 27;
    local $lotext = $main::session_id ? $text{'main_logout'} : $text{'main_switch'};
    if (!$ENV{'ANONYMOUS_USER'}) {
    if ($gconfig{'nofeedbackcc'} != 2 && $gaccess{'feedback'} &&
        (!$module_name || $module_info{'longdesc'} || $module_info{'feedback'})) {
            $feedback_link = "<a href='$gconfig{'webprefix'}/feedback_form.cgi?module=$module_name'>$text{'main_feedback'}</a>";
		}
        if (!$ENV{'SSL_USER'} && !$ENV{'LOCAL_USER'} &&
            !$ENV{'HTTP_WEBMIN_SERVERS'}) {
            $logout_link = "<a href='$gconfig{'webprefix'}$logout'><i class='fa fa-sign-out'></i> $lotext</a>";
		}
	}
}

# Virtualmin

$hasvirt = &foreign_available("virtual-server");
if ($hasvirt) {
	%minfo = &get_module_info("virtual-server");
	%vconfig = &foreign_config("virtual-server");
    %vserver_lang = load_language('virtual-server');
	$hasvirt = 0 if ($minfo{'version'} < 2.99);
}

$hasmail = &foreign_available("mailbox");
$hasvm2 = &foreign_available("server-manager");

if ($hasvirt) {
	&foreign_require("virtual-server", "virtual-server-lib.pl");
	$is_master = &virtual_server::master_admin();
}

# if ($hasvm2) {
# 	&foreign_require("server-manager", "server-manager-lib.pl");
# }
if (defined(&virtual_server::get_provider_link)) {
	(undef, $image, $link) = &virtual_server::get_provider_link();
}
if (!$image && defined(&server_manager::get_provider_link)) {
	(undef, $image, $link) = &server_manager::get_provider_link();
}
if ($image) {
	print "<a href='$link' target='_new'>" if ($link);
	print "<center><img src='$image' alt=''></center>";
	print "</a><br>\n" if ($link);
}

if ($hasvirt) {
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

# Webmin categories

$webmin_categories .= "\
    <li class='dropdown'>\
        <a class='dropdown-toggle' data-toggle='dropdown' data-hover='dropdown'>Webmin</a>";

$webmin_categories .= "<ul class='dropdown-menu'>";

foreach $category (@categories) {
    local $catdesc = $text{'longcategory_'.$category};
    local $category_name = $text{'category_'.$category};
    $webmin_categories .= "<li class='dropdown-submenu'><a href='#'>$category_name</a>";
    local $category_sublist = "<ul class='dropdown-menu'>";
	foreach $m (@visible_modules) {
    	next if ($m->{'category'} ne $category);
		$category_sublist .= "<li>\
		<a class='ajax' href='/$m->{'dir'}/'>\
        <img src='images/$m->{'dir'}/images/icon.gif' border=0 \
        width=24 height=24 title=\"$desc\">\
		$m->{'desc'}</a></li>";
	}
	$category_sublist .= '</li></ul>';
    $webmin_categories .= "$category_sublist";
}
$webmin_categories .= "</ul></li>";

# Virtualmin Categories

$virtualmin_categories = "\
    <li class='dropdown'>\
        <a class='dropdown-toggle' data-toggle='dropdown' data-hover='dropdown'>Virtualmin</a>";
$virtualmin_categories .= "<ul class='dropdown-menu'>";

my @buts = &virtual_server::get_all_global_links();
my @tcats = &unique(map { $_->{'cat'} } @buts);
foreach my $tc (@tcats) {
	my @incat = grep { $_->{'cat'} eq $tc } @buts;
	if ($tc) {
		$virtualmin_categories .= "<li class='dropdown-submenu'>\
		<a href='#'>$incat[0]->{'catname'}</a>\
        <ul class='dropdown-menu'>";
		foreach my $l (@incat) {
            $virtualmin_categories .= "<li>\
            <a class='ajax' href='$l->{'url'}'>\
            <img src='images/virtual-server/images/$l->{'icon'}.png' width='24' height='24'>\
            $l->{'title'}</a></li>";
	    }
    	$virtualmin_categories .= '</ul></li>';
    }
}
$virtualmin_categories .= "</ul></li>";

# Main menu

$main_menu = "<ul class='nav navbar-nav'>";
$main_menu .= $webmin_categories;
$main_menu .= $virtualmin_categories;
$main_menu .= "</ul>";

if (!@visible_modules) {
	# user has no modules!
	print "<p><b>$text{'main_none'}</b><p>\n";
}

if ($miniserv{'logout'} && !$gconfig{'alt_startpage'} &&
    !$ENV{'SSL_USER'} && !$ENV{'LOCAL_USER'} &&
    $ENV{'HTTP_USER_AGENT'} !~ /webmin/i) {
    $footer .= &text('main_version', $version, $hostname, $ostr)."\n" if (!$gconfig{'nohostname'});
    $footer .= $text{'main_readonly'}."\n" if (&is_readonly_mode());
}

$doms.= &list_virtualmin_domains();

print_template('index.html');

if (&foreign_check("webmin")) {
	&foreign_require("webmin", "webmin-lib.pl");
	&webmin::show_webmin_notifications();
}
