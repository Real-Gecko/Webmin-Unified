#!/usr/bin/perl
# allmanual_form.cgi
# Display a text box for manually editing directives from one of the files

require './apache-lib.pl';
&ReadParse();
$access{'types'} eq '*' && $access{'virts'} eq '*' ||
	&error($text{'manual_ecannot'});
&ui_print_header(undef, $text{'manual_configs'}, "");

$conf = &get_config();
@files = grep { -f $_ } &unique(map { $_->{'file'} } @$conf);
$in{'file'} = $files[0] if (!$in{'file'});
foreach $f (@files) {
	$found++ if ($f eq $in{'file'});
}
print &ui_form_start('allmanual_form.cgi', 'post');
print &ui_submit($text{'manual_file'});
print &ui_select('file', $in{'file'}, \@files);
print &ui_form_end();
$found || &error($text{'manual_efile'});

print &ui_form_start("allmanual_save.cgi", "form-data");
print &ui_hidden("file", $in{'file'}),"\n";
$data = &read_file_contents($in{'file'});
print &ui_textarea("data", $data, 20, 80, undef, undef,
		   "style='width:100%'"),"<br>\n";
print &ui_form_end([ [ "save", $text{'save'} ] ]);

&ui_print_footer("index.cgi?mode=global", $text{'index_return2'});
