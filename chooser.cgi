#!/usr/bin/perl
# chooser.cgi
# Outputs HTML for a frame-based file chooser 

BEGIN { push(@INC, ".."); };
use WebminCore;

require './unified/unified.pl'; # Don't ask me why :D

&load_theme_library();

&init_config();
if (&get_product_name() eq 'usermin') {
	&switch_to_remote_user();
}
%access = &get_module_acl();

# Work out root directory
local @uinfo = getpwnam($remote_user);
if (!$access{'root'}) {
	$rootdir = $uinfo[7] ? $uinfo[7] : "/";
} else {
	$rootdir = $access{'root'};
	$rootdir =~ s/^\~/$uinfo[7]/;
}

# Switch to correct Unix user
if (&supports_users()) {
	if (&get_product_name() eq 'usermin') {
		# Always run as Usermin login
		&switch_to_remote_user();
	} else {
		# ACL determines
		$fileunix = $access{'fileunix'} || $remote_user;
		@uinfo = getpwnam($fileunix);
		if (@uinfo) {
			&switch_to_unix_user(\@uinfo);
		}
	}
}

&ReadParse(undef, undef, 1);

# If a chroot is forced which is under the allowed root, there is no need for
# a restrictred root
if ($in{'chroot'} && $in{'chroot'} ne '/' && $rootdir && $rootdir ne '/' &&
    $in{'chroot'} =~ /^\Q$rootdir\E/) {
	$rootdir = undef;
}

if ($gconfig{'os_type'} eq 'windows') {
	# On Windows, chroot should be empty if not use, and default path
	# should be c:/
	if ($in{'chroot'} eq "/") {
		$in{'chroot'} = "";
	}
	if ($rootdir eq "/") {
		$rootdir = "c:";
	}
}
if ($in{'add'}) {
	# Only use last filename by default
	$in{'file'} =~ s/\s+$//;
	if ($in{'file'} =~ /\n(.*)$/) {
		$in{'file'} = $1;
	}
}
if ($in{'file'} =~ /^(([a-z]:)?.*\/)([^\/]*)$/i && $in{'file'} !~ /\.\./) {
	# File entered is valid
	$dir = $1;
	$file = $3;
}
else {
	# Fall back to default
	$dir = $rootdir;
	$dir .= '/' if ($dir !~ /\/$/);
	$file = "";
}
$add = int($in{'add'});

if (!(-d $in{'chroot'}.$dir)) {
	# Entered directory does not exist
	$dir = $rootdir.'/';
	$file = "";
}
if (!&allowed_dir($dir)) {
	# Directory is outside allowed root
	$dir = $rootdir.'/';
	$file = "";
}

# Work out the top allowed dir
$topdir = $rootdir eq "/" || $rootdir eq "c:" ? $rootdir : $access{'otherdirs'} ? "/" : $rootdir;
$uchroot = &urlize($in{'chroot'});
$utype = &urlize($in{'type'});
$ufile = &urlize($in{'file'});

&PrintHeader();

print "<h4 class='text-center'>",&text('chooser_dir', &html_escape($dir)),"</h4>\n";
opendir(DIR, $in{'chroot'}.$dir) || &popup_error(&text('chooser_eopen', "$!"));
my @headings = ("", $text{'uptracker_file'}, $text{'uptracker_size'}, "D", "T");
print &ui_columns_start(\@headings, 100);
# $select_button = "<button type='button' class='chooser-success btn btn-success btn-xs'>\
# 	<i class='fa fa-check'></i></button>";
# $disabled_button = "<button type='button' class='btn btn-default btn-xs disabled'><i class='fa fa-close'></i></button>";
my $cnt = 0;
foreach $f (sort { $a cmp $b } readdir(DIR)) {
	$path = "$in{'chroot'}$dir$f";
	if ($f eq ".") { next; }
	if ($f eq ".." && ($dir eq "/" || $dir eq $topdir.'/')) { next; }
	if ($f =~ /^\./ && $f ne ".." && $access{'nodot'}) { next; }
	if (!(-d $path) && $in{'type'} == 1) { next; }

	@st = stat($path);
	$isdir = 0; undef($icon);
	if (-d $path) {
	    $icon = "filemin/images/icons/mime/inode-directory.png";
	    $isdir = 1;
		if ($f eq "..") {
			$dir =~ /^(.*\/)[^\/]+\/$/;
			$link = "<a class='chooser-url' data-file='$dir$f/' chroot='$chroot' href='/chooser.cgi?frame=1&add=0&chroot=/&type=$utype&file=".&quote_javascript($1)."'>";
# 			$link = "$disabled_button <a class='chooser-url' file='$dir$f/' chroot='$chroot' href='/chooser.cgi?frame=1&add=0&chroot=/&type=$utype&file=".&quote_javascript($1)."'>";
		}
		else {
			$link = "<a class='chooser-url' data-file='$dir$f/' chroot='$chroot' href='/chooser.cgi?frame=1&add=0&chroot=/&type=$utype&file=".&quote_javascript("$dir$f/")."'>";
# 			$link = "$select_button <a class='chooser-url' file='$dir$f/' chroot='$chroot' href='/chooser.cgi?frame=1&add=0&chroot=/&type=$utype&file=".&quote_javascript("$dir$f/")."'>";
		}
    }
	elsif ($path =~ /\.([^\.\/]+)$/) {
	    $mime = guess_mime_type($path);
	    $mime =~ s/\//-/ig;
	    $icon = "filemin/images/icons/mime/$mime.png"; # Grab cool icons from Filemin
        $link = "<a class='chooser-url' data-file='$dir$f'>";
        # $link = "$select_button <a class='chooser-url' file='$dir$f'>";
    } else {
        $link = "<a class='chooser-url' data-file='$dir$f'>";
        # $link = "$select_button <a class='chooser-url' file='$dir$f'>";
    }
	if (!$icon) { $icon = "filemin/images/icons/mime/unknown.png"; }

	local @cols;
 	push(@cols, "");
	push(@cols, "$link<img src=$gconfig{'webprefix'}/$icon> ".&html_escape($f)."</a>");
#		push(@cols, "$link".&html_escape($f)."</a>");
	push(@cols, &nice_size($st[7]));
	@tm = localtime($st[9]);
	push(@cols, sprintf "<tt>%.2d/%s/%.4d</tt>", $tm[3], $text{'smonth_'.($tm[4]+1)}, $tm[5]+1900);
	push(@cols, sprintf "<tt>%.2d:%.2d</tt>", $tm[2], $tm[1]);
	print &ui_columns_row(\@cols);
	$cnt++;
}
closedir(DIR);
print &ui_columns_end();

# allowed_dir(dir)
# Returns 1 if some directory should be listable
sub allowed_dir {
    local ($dir) = @_;
    return 1 if ($rootdir eq "" || $rootdir eq "/" || $rootdir eq "c:");
    foreach my $allowed ($rootdir, split(/\t+/, $access{'otherdirs'})) {
    	return 1 if (&is_under_directory($allowed, $dir));
	}
    return 0;
}

sub list_mime_types {
    if (!@list_mime_types_cache) {
    	local $_;
    	open(MIME, "$root_directory/unified/mime.types");
    	while(<MIME>) {
    		my $cmt;
    		s/\r|\n//g;
    		if (s/#\s*(.*)$//g) {
    			$cmt = $1;
    			}
    		my ($type, @exts) = split(/\s+/);
    		if ($type) {
    			push(@list_mime_types_cache, { 'type' => $type,
    						       'exts' => \@exts,
    						       'desc' => $cmt });
			}
		}
    	close(MIME);
	}
    return @list_mime_types_cache;
}

sub guess_mime_type {
    if ($_[0] =~ /\.([A-Za-z0-9\-]+)$/) {
    	my $ext = $1;
    	foreach my $t (list_mime_types()) {
    		foreach my $e (@{$t->{'exts'}}) {
    			return $t->{'type'} if (lc($e) eq lc($ext));
			}
		}
	}
    return @_ > 1 ? $_[1] : "unknown";
}
