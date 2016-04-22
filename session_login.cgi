#!/usr/bin/perl
# session_login.cgi
# Display the login form used in session login mode

BEGIN { push(@INC, ".."); };
use WebminCore;
require './unified/unified.pl';

$pragma_no_cache = 1;
&init_config();
&ReadParse();
if ($gconfig{'loginbanner'} && $ENV{'HTTP_COOKIE'} !~ /banner=1/ &&
    !$in{'logout'} && !$in{'failed'} && !$in{'timed_out'}) {
	# Show pre-login HTML page
	print "Set-Cookie: banner=1; path=/\r\n";
	&PrintHeader();
	$url = $in{'page'};
	open(BANNER, $gconfig{'loginbanner'});
	while(<BANNER>) {
		s/LOGINURL/$url/g;
		print;
	}
	close(BANNER);
	return;
}
$sec = uc($ENV{'HTTPS'}) eq 'ON' ? "; secure" : "";
if (!$config{'no_httponly'}) {
	$sec .= "; httpOnly";
}
&get_miniserv_config(\%miniserv);
$sidname = $miniserv{'sidname'} || "sid";
print "Set-Cookie: banner=0; path=/$sec\r\n" if ($gconfig{'loginbanner'});
print "Set-Cookie: $sidname=x; path=/$sec\r\n" if ($in{'logout'});
print "Set-Cookie: testing=1; path=/$sec\r\n";
$title = $text{'session_header'};
if ($gconfig{'showhost'}) {
    $title = &get_display_hostname()." : ".$title;
}

&header();

if (defined($in{'failed'})) {
	if ($in{'twofactor_msg'}) {
		$login_message = "<div class='alert alert-danger text-center'>".&text('session_twofailed'.
			&html_escape($in{'twofactor_msg'}))."</div>\n";
	} else {
		$login_message = "<div class='alert alert-danger text-center'>$text{'session_failed'}</div>";
	}
} elsif ($in{'logout'}) {
	$login_message = "<div class='alert alert-warning text-center'>$text{'session_logout'}</div>";
} elsif ($in{'timed_out'}) {
	$login_message = "<div class='alert alert-danger text-center'>".&text('session_timed_out', int($in{'timed_out'}/60))."</div>";
}

# Login message
if ($gconfig{'realname'}) {
	$host = &get_display_hostname();
} else {
	$host = $ENV{'HTTP_HOST'};
	$host =~ s/:\d+//g;
	$host = &html_escape($host);
}

$session_mesg = "<p class='bg-info'>".
                &text($gconfig{'nohostname'} ? 'session_mesg2' : 'session_mesg', "<tt>$host</tt>").
                "</p>";

# Username and password
$tags = $gconfig{'noremember'} ? "autocomplete=off" : "";

# Two-factor token, for users that have it
if ($miniserv{'twofactor_provider'}) {
	$two_factor .= $text{'session_twofactor'}.
	            &ui_textbox("twofactor", undef, 20, 0, undef, "autocomplete=off");
}

# Remember session cookie?
if (!$gconfig{'noremember'}) {
    $session_save = "\
        <div class='form-group'>\
        <div class='checkbox'>\
        <label>\
        <input type='checkbox' name='save'> $text{'session_save'}\
        </label>\
        </div>\
        </div>";
}

print_template('login.html');
