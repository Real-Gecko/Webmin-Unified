# Some config
&init_config();
$templates_path =  "$root_directory/$current_theme/unauthenticated/templates";
$webprefix = $gconfig{'webprefix'};
$module_name = &get_module_name();
$prefix_uri = "$webprefix/$module_name";

sub theme_ui_link {
    my ($href, $text, $class, $tags) = @_;
    my $module_name = &get_module_name();
    my $prefix_uri = "$webprefix/$module_name";
    return ("<a class='ui_link ajax".($class ? " ".$class : "")."' href='$prefix_uri/$href'".($tags ? " ".$tags : "").">$text</a>");
}

sub theme_ui_img {
    my ($src, $alt, $title, $class, $tags) = @_;
#    my $module_name = &get_module_name();
    my $module_name = &get_module_name();
    my $prefix_uri = "$webprefix/$module_name";
    return ("<img src='$prefix_uri/$src' class='ui_img".($class ? " ".$class : "")."' alt='$alt' ".($title ? "title='$title'" : "").($tags ? " ".$tags : "").">");
}

=head2 ui_table_start(heading, [tabletags], [cols], [&default-tds], [right-heading])

Returns HTML for the start of a form block into which labelled inputs can
be placed. By default this is implemented as a table with another table inside
it, but themes may override this with their own layout.

The parameters are :
=item heading - Text to show at the top of the form.
=item tabletags - HTML attributes to put in the outer <table>, typically something like width=100%.
=item cols - Desired number of columns for labels and fields. Defaults to 4, but can be 2 for forms with lots of wide inputs.
=item default-tds - An optional array reference of HTML attributes for the <td> tags in each row of the table.
=item right-heading - HTML to appear in the heading, aligned to the right.
=cut
sub theme_ui_table_start {
    my ($heading, $tabletags, $cols, $tds, $rightheading) = @_;
    if (defined($main::ui_table_cols)) {
    	# Push on stack, for nested call
    	push(@main::ui_table_cols_stack, $main::ui_table_cols);
    	push(@main::ui_table_pos_stack, $main::ui_table_pos);
    	push(@main::ui_table_default_tds_stack, $main::ui_table_default_tds);
	}
#    my $colspan = 1;
    my $rv;
#    $rv .= "<table class='ui_table' border $tabletags>\n";
    if (defined($heading) || defined($rightheading)) {
        $rv .= "<div class='text-center'>";
    	if (defined($heading)) {
#    		$rv .= "<td><b>$heading</b></td>"
    		$rv .= "<h4>$heading</h4>";
		}
		# comment for now
#    	if (defined($rightheading)) {
#    		$rv .= "<td align=right>$rightheading</td>";
#    		$colspan++;
#                $rv .= "<div class='pull-right'>$rightheading</div>";
#		}
    	$rv .= "</div><hr>\n";
	}
    $rv .= "<table class='table table-stripped table-condensed'>\n";
    $main::ui_table_cols = $cols || 4;
    $main::ui_table_pos = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

sub theme_ui_table_end {
    my $rv;
    if ($main::ui_table_cols == 4 && $main::ui_table_pos) {
    	# Add an empty block to balance the table
    	$rv .= &ui_table_row(" ", " ");
	}
    if (@main::ui_table_cols_stack) {
    	$main::ui_table_cols = pop(@main::ui_table_cols_stack);
    	$main::ui_table_pos = pop(@main::ui_table_pos_stack);
    	$main::ui_table_default_tds = pop(@main::ui_table_default_tds_stack);
	}
    else {
    	$main::ui_table_cols = undef;
    	$main::ui_table_pos = undef;
    	$main::ui_table_default_tds = undef;
	}
#    $rv .= "</table></td></tr></table>\n";
#    $rv .= "</tbody></table>\n";
    $rv .= "</table>\n";
    return $rv;
}

sub theme_ui_table_row {
    my ($label, $value, $cols, $tds) = @_;
    $cols ||= 1;
    $tds ||= $main::ui_table_default_tds;
    my $rv;
    if ($main::ui_table_pos+$cols+1 > $main::ui_table_cols &&
        $main::ui_table_pos != 0) {
    	# If the requested number of cols won't fit in the number
    	# remaining, start a new row
    	my $leftover = $main::ui_table_cols - $main::ui_table_pos;
    	$rv .= "<td colspan=$leftover></td>\n";
    	$rv .= "</tr>\n";
    	$main::ui_table_pos = 0;
	}
    $rv .= "<tr class='ui_table_row'>\n" if ($main::ui_table_pos%$main::ui_table_cols == 0);
    if (defined($label) &&
        ($value =~ /id="([^"]+)"/ || $value =~ /id='([^']+)'/ ||
         $value =~ /id=([^>\s]+)/)) {
        	# Value contains an input with an ID
        	my $id = $1;
        	$label = "<label for=\"".&quote_escape($id)."\">$label</label>";
	}
    $rv .= "<td valign=top $tds->[0] class='ui_label'><b>$label</b></td>\n"
    	if (defined($label));
    $rv .= "<td valign=top colspan=$cols $tds->[1] class='ui_value'>$value</td>\n";
    $main::ui_table_pos += $cols+(defined($label) ? 1 : 0);
    if ($main::ui_table_pos%$main::ui_table_cols == 0) {
    	$rv .= "</tr>\n";
    	$main::ui_table_pos = 0;
	}
    return $rv;
}

sub theme_ui_table_hr {
    my $rv;
    if ($ui_table_pos) {
    	$rv .= "</tr>\n";
    	$ui_table_pos = 0;
	}
    $rv .= "<tr class='ui_table_hr'><td colspan=$main::ui_table_cols><hr></td></tr>\n";
    return $rv;
}

sub theme_ui_table_span {
    my ($text) = @_;
    my $rv;
    if ($ui_table_pos) {
    	$rv .= "</tr>\n";
    	$ui_table_pos = 0;
	}
    $rv .= "<tr class='ui_table_span'><td colspan=$main::ui_table_cols>$text</td></tr>\n";
    return $rv;
}

sub theme_ui_columns_start {
    my ($heads, $width, $noborder, $tdtags, $title) = @_;
    my $rv;
    if ($title) {
        $rv .= "<div class='text-center'><h4>title</h4></div><hr>\n";
	}
    $rv .= "<table data-toggle='table' class='ui_columns table'".
    		(defined($width) ? " width='$width%'" : "").">\n";
    if(scalar $heads > 0) {
        $rv .= "<thead><tr class='ui_columns_heads'>\n";
        my $i;
        for($i=0; $i<@$heads; $i++) {
            my $sort_filter = $heads->[$i] eq "" ? "" : " data-sortable='true' data-sorter='alphanum' data-filter-control='input'";
        	$rv .= "<th$sort_filter data-field='f$i' ".$tdtags->[$i].">".
        	       ($heads->[$i] eq "" ? "<br>" : $heads->[$i])."</th>\n";
    	}
        $rv .= "</tr></thead>\n";
    }
    $rv .= "<tbody>\n";
    return $rv;
}

sub theme_ui_columns_row {
    my ($cols, $tdtags) = @_;
    my $rv;
    $rv .= "<tr class='ui_columns_row'>\n";
    my $i;
    for($i=0; $i<@$cols; $i++) {
    	$rv .= "<td ".$tdtags->[$i].">".
    	       ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i])."</td>\n";
    	}
    $rv .= "</tr>\n";
    return $rv;
}

sub theme_ui_columns_header {
    my ($cols, $tdtags) = @_;
    my $rv;
    $rv .= "<tr class='ui_columns_header'>\n";
    my $i;
    for($i=0; $i<@$cols; $i++) {
    	$rv .= "<td ".$tdtags->[$i]."><b>".
    	       ($cols->[$i] eq "" ? "<br>" : $cols->[$i])."</b></td>\n";
    	}
    $rv .= "</tr>\n";
    return $rv;
}

sub theme_ui_checked_columns_row {
    my ($cols, $tdtags, $checkname, $checkvalue, $checked, $disabled, $tags) = @_;
    my $rv;
    $rv .= "<tr class='ui_checked_columns'>\n";
    $rv .= "<td class='ui_checked_checkbox' ".$tdtags->[0].">".
           &ui_checkbox($checkname, $checkvalue, undef, $checked, $tags, $disabled).
           "</td>\n";
    my $i;
    for($i=0; $i<@$cols; $i++) {
    	$rv .= "<td ".$tdtags->[$i+1].">";
    	if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
    		$rv .= "<label for=\"".
    			&quote_escape("${checkname}_${checkvalue}")."\">";
    		}
    	$rv .= ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i]);
    	if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
    		$rv .= "</label>";
    		}
    	$rv .= "</td>\n";
    	}
    $rv .= "</tr>\n";
    return $rv;
}

sub theme_ui_radio_columns_row {
    my ($cols, $tdtags, $checkname, $checkvalue, $checked, $dis, $tags) = @_;
    my $rv;
    $rv .= "<tr class='ui_radio_columns'>\n";
    $rv .= "<td class='ui_radio_radio' ".$tdtags->[0].">".
        &ui_oneradio($checkname, $checkvalue, "", $checked, undef, $dis)."</td>\n";
    my $i;
    for($i=0; $i<@$cols; $i++) {
    	$rv .= "<td ".$tdtags->[$i+1].">";
    	if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
    		$rv .= "<label for=\"".
    			&quote_escape("${checkname}_${checkvalue}")."\">";
    		}
    	$rv .= ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i]);
    	if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
    		$rv .= "</label>";
    		}
    	$rv .= "</td>\n";
    	}
    $rv .= "</tr>\n";
    return $rv;
}

sub theme_ui_columns_end {
    return "</tbody></table>\n";
}

sub theme_ui_columns_table
{
    my ($heads, $width, $data, $types, $nosort, $title, $emptymsg) = @_;
    my $rv;
    
    # Just show empty message if no data
    if ($emptymsg && !@$data) {
    	$rv .= &ui_subheading($title) if ($title);
    	$rv .= "<span class='ui_emptymsg'><b>$emptymsg</b></span><p>\n";
    	return $rv;
	}
    
    # Are there any checkboxes in each column? If so, make those columns narrow
    my @tds = map { "valign=top" } @$heads;
    my $maxwidth = 0;
    foreach my $r (@$data) {
    	my $cc = 0;
    	foreach my $c (@$r) {
    		if (ref($c) &&
    		    ($c->{'type'} eq 'checkbox' || $c->{'type'} eq 'radio')) {
    			$tds[$cc] .= " width=5" if ($tds[$cc] !~ /width=/);
    			}
    		$cc++;
    		}
    	$maxwidth = $cc if ($cc > $maxwidth);
    	}
    $rv .= &ui_columns_start($heads, $width, 0, \@tds, $title);
    
    # Add the data rows
    foreach my $r (@$data) {
    	my $c0;
    	if (ref($r->[0]) && ($r->[0]->{'type'} eq 'checkbox' ||
    			     $r->[0]->{'type'} eq 'radio')) {
    		# First column is special
    		$c0 = $r->[0];
    		$r = [ @$r[1..(@$r-1)] ];
    		}
    	# Turn data into HTML
    	my @rtds = @tds;
    	my @cols;
    	my $cn = 0;
    	$cn++ if ($c0);
    	foreach my $c (@$r) {
    		if (!ref($c)) {
    			# Plain old string
    			push(@cols, $c);
    			}
    		elsif ($c->{'type'} eq 'checkbox') {
    			# Checkbox in non-first column
    			push(@cols, &ui_checkbox($c->{'name'}, $c->{'value'},
    					         $c->{'label'}, $c->{'checked'},
    						 $c->{'tags'},
    						 $c->{'disabled'}));
    			}
    		elsif ($c->{'type'} eq 'radio') {
    			# Radio button in non-first column
    			push(@cols, &ui_oneradio($c->{'name'}, $c->{'value'},
    					         $c->{'label'}, $c->{'checked'},
    						 $c->{'tags'},
    						 $c->{'disabled'}));
    			}
    		elsif ($c->{'type'} eq 'group') {
    			# Header row that spans whole table
    			$rv .= &ui_columns_header([ $c->{'desc'} ],
    						  [ "colspan=$width" ]);
    			next;
    			}
    		elsif ($c->{'type'} eq 'string') {
    			# A string, which might be special
    			push(@cols, $c->{'value'});
    			if ($c->{'columns'} > 1) {
    				splice(@rtds, $cn, $c->{'columns'},
    				       "colspan=".$c->{'columns'});
    				}
    			if ($c->{'nowrap'}) {
    				$rtds[$cn] .= " nowrap";
    				}
    			}
    		$cn++;
    		}
    	# Add the row
    	if (!$c0) {
    		$rv .= &ui_columns_row(\@cols, \@rtds);
    		}
    	elsif ($c0->{'type'} eq 'checkbox') {
    		$rv .= &ui_checked_columns_row(\@cols, \@rtds, $c0->{'name'},
    					       $c0->{'value'}, $c0->{'checked'},
    					       $c0->{'disabled'},
    					       $c0->{'tags'});
    		}
    	elsif ($c0->{'type'} eq 'radio') {
    		$rv .= &ui_radio_columns_row(\@cols, \@rtds, $c0->{'name'},
    					     $c0->{'value'}, $c0->{'checked'},
    					     $c0->{'disabled'},
    					     $c0->{'tags'});
    		}
    	}
    
    $rv .= &ui_columns_end();
    return $rv;
}

=head2 ui_form_start(script, method, [target], [tags])

Returns HTML for the start of a a form that submits to some script. The
parameters are :

=item script - CGI script to submit to, like save.cgi.
=item method - HTTP method, which must be one of 'get', 'post' or 'form-data'. If form-data is used, the target CGI must call ReadParseMime to parse parameters.
=item target - Optional target window or frame for the form.
=item tags - Additional HTML attributes for the form tag.
=cut
sub theme_ui_form_start {
    $ui_formcount ||= 0;
    my ($script, $method, $target, $tags) = @_;
    my $module_name = &get_module_name();
    my $rv;
#    $rv .= "<form class='ui_form' action='$module_name/".&html_escape($script)."' ".
    $prefix = $module_name ? "/$module_name/" : "";
    $rv .= "<form class='ui_form form-inline' action='$prefix".&html_escape($script)."' ".
#    $rv .= "<form class='ui_form' action='/$module_name/".&html_escape($script)."' ".
    	($method eq "post" ? "method='post'" :
    	 $method eq "form-data" ?
    		"method='post' enctype='multipart/form-data'" :
    		"method='get'").
    	($target ? " target=$target" : "").
            ($tags ? " ".$tags : "").">\n";
    return $rv;
}

sub theme_ui_password {
    my ($name, $value, $size, $dis, $max, $tags) = @_;
    $size = &ui_max_text_width($size);
    return "<input class='ui_password form-control input-sm' type='password' ".
           "name=\"".&quote_escape($name)."\" ".
           "id=\"".&quote_escape($name)."\" ".
           ($value ne "" ? "value=\"".&quote_escape($value)."\" " : "").
           "size=$size".($dis ? " disabled=true" : "").
           ($max ? " maxlength=$max" : "").
           ($tags ? " ".$tags : "").">";
}

sub theme_ui_checkbox {
    my ($name, $value, $label, $sel, $tags, $dis) = @_;
    my $after;
    if ($label =~ /^([^<]*)(<[\000-\377]*)$/) {
    	$label = $1;
    	$after = $2;
	}
    return "<input class='ui_checkbox' type='checkbox' ".
           "name=\"".&quote_escape($name)."\" ".
           "value=\"".&quote_escape($value)."\" ".
           ($sel ? " checked" : "").($dis ? " disabled=true" : "").
           " id=\"".&quote_escape("${name}_${value}")."\"".
           ($tags ? " ".$tags : "")."> ".
           ($label eq "" ? $after :
    	 "<label for=\"".&quote_escape("${name}_${value}").
    	 "\">$label</label>$after")."\n";
}

sub theme_ui_oneradio {
    my ($name, $value, $label, $sel, $tags, $dis) = @_;
    my $id = &quote_escape("${name}_${value}");
    my $after;
    if ($label =~ /^([^<]*)(<[\000-\377]*)$/) {
    	$label = $1;
    	$after = $2;
	}
    my $ret = "<input class='ui_radio' type='radio' name=\"".&quote_escape($name)."\" ".
           "value=\"".&quote_escape($value)."\" ".
           ($sel ? " checked" : "").($dis ? " disabled=true" : "").
           " id=\"$id\"".
           ($tags ? " ".$tags : "").">";
        $ret .= " <label for=\"$id\">$label</label>" if ($label ne '');
        $ret .= "$after\n";
        return $ret;
}

sub theme_ui_textarea {
    my ($name, $value, $rows, $cols, $wrap, $dis, $tags) = @_;
    $cols = &ui_max_text_width($cols, 1);
    return "<textarea class='ui_textarea form-control' ".
           "name=\"".&quote_escape($name)."\" ".
           "id=\"".&quote_escape($name)."\" ".
           "rows='$rows' cols='$cols'".($wrap ? " wrap=$wrap" : "").
           ($dis ? " disabled=true" : "").
           ($tags ? " $tags" : "").">".
           &html_escape($value).
           "</textarea>";
}

sub theme_ui_table_span {
    my ($text) = @_;
    my $rv;
    if ($ui_table_pos) {
    	$rv .= "</tr>\n";
    	$ui_table_pos = 0;
    	}
    $rv .= "<tr class='ui_table_span'> ".
           "<td colspan=$main::ui_table_cols>$text</td> </tr>\n";
    return $rv;
}

=head2 ui_textbox(name, value, size, [disabled?], [maxlength], [tags])

Returns HTML for a text input box. The parameters are :

=item name - Name for this input.
=item value - Initial contents for the text box.
=item size - Desired width in characters.
=item disabled - Set to 1 if this text box should be disabled by default.
=item maxlength - Maximum length of the string the user is allowed to input.
=item tags - Additional HTML attributes for the <input> tag.
=cut
sub theme_ui_textbox {
    my ($name, $value, $size, $dis, $max, $tags) = @_;
    $size = &ui_max_text_width($size);
    return "<input class='ui_textbox form-control input-sm' type='text' ".
           "name=\"".&html_escape($name)."\" ".
           "id=\"".&html_escape($name)."\" ".
           "value=\"".&html_escape($value)."\" ".
           "size=$size".($dis ? " disabled=true" : "").
           ($max ? " maxlength=$max" : "").
           ($tags ? " ".$tags : "").">";
}

sub theme_ui_submit {
    my ($label, $name, $dis, $tags) = @_;
    my $rv;
    $rv = "<input class='ui_submit btn btn-sm btn-primary' type='submit'".
           ($name ne '' ? " name=\"".&quote_escape($name)."\"" : "").
           ($name ne '' ? " id=\"".&quote_escape($name)."\"" : "").
           " value=\"".&quote_escape($label)."\"".
           ($dis ? " disabled=true" : "").
           ($tags ? " ".$tags : "").">\n";
    # Duplicate input as hidden for AJAX form submission
    $rv .= "<input type='hidden'".
           ($name ne '' ? " name=\"".&quote_escape($name)."\"" : "").
           " value=\"".&quote_escape($label)."\">\n";
    return $rv;
}

sub theme_ui_reset {
    my ($label, $dis, $tags) = @_;
    return "<input class='ui_reset btn btn-sm btn-warning' type='reset' value=\"".&quote_escape($label)."\"".
           ($dis ? " disabled=true" : "").
           ($tags ? " ".$tags : "").">\n";		
}

sub theme_ui_button {
    my ($label, $name, $dis, $tags) = @_;
    return "<input class='ui_button btn btn-default' type='button'".
           ($name ne '' ? " name=\"".&quote_escape($name)."\"" : "").
           ($name ne '' ? " id=\"".&quote_escape($name)."\"" : "").
           " value=\"".&quote_escape($label)."\"".
           ($dis ? " disabled=true" : "").
           ($tags ? " ".$tags : "").">\n";
}

sub theme_ui_select {
    my ($name, $value, $opts, $size, $multiple, $missing, $dis, $tags) = @_;
    my $rv;
    $rv .= "<select class='ui_select selectpicker' ".
           "name=\"".&quote_escape($name)."\" ".
           "id=\"".&quote_escape($name)."\" ".
           ($size ? " size=$size" : "").
           ($multiple ? " multiple" : "").
           ($dis ? " disabled=true" : "").($tags ? " ".$tags : "").">\n";
    my ($o, %opt, $s);
    my %sel = ref($value) ? ( map { $_, 1 } @$value ) : ( $value, 1 );
    foreach $o (@$opts) {
        $o = [ $o ] if (!ref($o));
        $rv .= "<option value=\"".&quote_escape($o->[0])."\"".
                ($sel{$o->[0]} ? " selected" : "").($o->[2] ne '' ? " ".$o->[2] : "").">".
                ($o->[1] || $o->[0])."</option>\n";
    	$opt{$o->[0]}++;
	}
    foreach $s (keys %sel) {
    	if (!$opt{$s} && $missing) {
    		$rv .= "<option value=\"".&quote_escape($s)."\"".
    		       " selected>".($s eq "" ? "&nbsp;" : $s)."</option>\n";
    		}
    	}
    $rv .= "</select>\n";
    return $rv;
}

sub theme_ui_multi_select {
    my ($name, $values, $opts, $size, $missing, $dis,
           $opts_title, $vals_title, $width) = @_;
    my $rv;
    my %already = map { $_->[0], $_ } @$values;
    my $leftover = [ grep { !$already{$_->[0]} } @$opts ];
    if ($missing) {
    	my %optsalready = map { $_->[0], $_ } @$opts;
    	push(@$opts, grep { !$optsalready{$_->[0]} } @$values);
	}
    if (!defined($width)) {
    	$width = "200";
	}
    my $wstyle = $width ? "style='width:$width'" : "";
    
    if (!$main::ui_multi_select_donejs++) {
    	$rv .= &ui_multi_select_javascript();
	}
    $rv .= "<table cellpadding=0 cellspacing=0 class='ui_multi_select'>";
    if (defined($opts_title)) {
    	$rv .= "<tr class='ui_multi_select_heads'>".
    	       "<td><b>$opts_title</b></td> ".
    	       "<td></td><td><b>$vals_title</b></td></tr>";
    	}
    $rv .= "<tr class='ui_multi_select_row'>";
    $rv .= "<td>".&ui_select($name."_opts", [ ], $leftover,
    			 $size, 1, 0, $dis, $wstyle)."</td>\n";
    $rv .= "<td>".&ui_button("->", $name."_add", $dis,
    		 "onClick='multi_select_move(\"$name\", form, 1)'")."<br>".
    	      &ui_button("<-", $name."_remove", $dis,
    		 "onClick='multi_select_move(\"$name\", form, 0)'")."</td>\n";
    $rv .= "<td>".&ui_select($name."_vals", [ ], $values,
    			 $size, 1, 0, $dis, $wstyle)."</td>\n";
    $rv .= "</tr></table>\n";
    $rv .= &ui_hidden($name, join("\n", map { $_->[0] } @$values));
    return $rv;
}

sub theme_ui_tabs_start {
    my ($tabs, $name, $sel, $border) = @_;
    my $rv;
    my $tabnames = "[".join(",", map { "\"".&quote_escape($_->[0])."\"" } @$tabs)."]";
    my $tabtitles = "[".join(",", map { "\"".&quote_escape($_->[1])."\"" } @$tabs)."]";
    $rv .= "<ul class='ui_tabs nav nav-tabs'>\n";
    foreach my $t (@$tabs) {
    	my $tabid = "#".$t->[0];
        if($t->[0] eq $sel) {
            $class = " class='active'";
        } else {
            $class = '';
        }
    	$rv .= "<li$class><a href='$tabid' class='ui_tab' data-toggle='tab'>$t->[1]</a></li>";
	}
    $main::ui_tabs_selected = $sel;
    $rv .= "</ul><div class='tab-content'>";
    return $rv;
}

sub theme_ui_tabs_end {
    return "</div>";
}

sub theme_ui_tabs_start_tab
{
    my ($name, $tab) = @_;
    if($tab eq $main::ui_tabs_selected) {
        $class = " active in";
    } else {
        $class = '';
    }
    my $rv = "<div class='tab-pane fade$class' id='$tab'>\n";
    return $rv;
}

sub theme_ui_tabs_end_tab {
    return "</div>\n";
}

sub theme_file_chooser_button {
    my $form = defined($_[2]) ? $_[2] : 0;
    my $chroot = defined($_[3]) ? $_[3] : "/";
    my $add = int($_[4]);
    my ($w, $h) = (400, 300);
    if ($gconfig{'db_sizefile'}) {
    	($w, $h) = split(/x/, $gconfig{'db_sizefile'});
	}
    return "<button data-field='$_[0]' data-url='$gconfig{'webprefix'}/chooser.cgi?add=$add&type=$_[1]&chroot=$chroot&file=' \
    class='btn btn-primary btn-sm chooser-open' type='button'>\
    <i class='fa fa-folder-open-o'></i></button>\n";
}

sub theme_ui_filebox {
    my ($name, $value, $size, $dis, $max, $tags, $dironly) = @_;
    return "<div class='input-group'>".
            &ui_textbox($name, $value, $size, $dis, $max, $tags).
            "<div class='input-group-btn'>".
            &file_chooser_button($name, $dironly).
            "</div></div>";
}

=head2 ui_user_textbox(name, value, [form], [disabled?], [tags])

Returns HTML for an input for selecting a Unix user. Parameters are the
same as ui_textbox.

=cut
sub theme_ui_user_textbox
{
#return &ui_textbox($_[0], $_[1], 13, $_[3], undef, $_[4])." "."";
#       &user_chooser_button($_[0], 0, $_[2]);
    local(@uinfo, @users, %ucan, %found);
    if ($access{'uedit_mode'} == 2 || $access{'uedit_mode'} == 3) {
    	map { $ucan{$_}++ } split(/\s+/, $access{'uedit'});
    	}
    setpwent();
    while(@uinfo = getpwent()) {
    	if ($access{'uedit_mode'} == 5 && $access{'uedit'} !~ /^\d+$/) {
    		# Get group for matching by group name
    		@ginfo = getgrgid($uinfo[3]);
		}
    	if ($access{'uedit_mode'} == 0 ||
    	    $access{'uedit_mode'} == 2 && $ucan{$uinfo[0]} ||
    	    $access{'uedit_mode'} == 3 && !$ucan{$uinfo[0]} ||
    	    $access{'uedit_mode'} == 4 &&
    		(!$access{'uedit'} || $uinfo[2] >= $access{'uedit'}) &&
    		(!$access{'uedit2'} || $uinfo[2] <= $access{'uedit2'}) ||
    	    $access{'uedit_mode'} == 5 &&
            ($access{'uedit'} =~ /^\d+$/ && $uinfo[3] == $access{'uedit'} ||
            $ginfo[0] eq $access{'uedit'})) {
                push(@users, [ @uinfo[0] ]) if (!$found{$uinfo[0]}++);
    		}
	}
    endpwent() if ($gconfig{'os_type'} ne 'hpux');
    use Data::Dumper;
    #return sort { $a->[0] cmp $b->[0] } @users;
    @users = sort { $a->[0] cmp $b->[0] } @users;
#    return "<pre>".Dumper(\@users)."</pre>";
    return ui_select($_[0], $_[1], \@users);#, undef, undef, undef, $_[2]);
}

sub theme_group_chooser_button {
    my $form = defined($_[2]) ? $_[2] : 0;
    my $w = $_[1] ? 500 : 300;
    my $h = 200;
    if ($_[1] && $gconfig{'db_sizeusers'}) {
    	($w, $h) = split(/x/, $gconfig{'db_sizeusers'});
	}
    elsif (!$_[1] && $gconfig{'db_sizeuser'}) {
    	($w, $h) = split(/x/, $gconfig{'db_sizeuser'});
	}
    return "<input type=button onClick='ifield = form.$_[0]; chooser = window.open(\"$gconfig{'webprefix'}/group_chooser.cgi?multi=$_[1]&group=\"+escape(ifield.value), \"chooser\", \"toolbar=no,menubar=no,scrollbars=yes,resizable=yes,width=$w,height=$h\"); chooser.ifield = ifield; window.ifield = ifield' value=\"...\">\n";
}

sub theme_ui_yesno_radio {
    my ($name, $value, $yes, $no, $dis) = @_;
    $yes = 1 if (!defined($yes));
    $no = 0 if (!defined($no));
    $value = int($value);
    return &ui_radio($name, $value, [ [ $yes, $text{'yes'} ], [ $no, $text{'no'} ] ], $dis);
}

sub theme_ui_buttons_start {
    return "<div class='btn-group' role='group'>\n";
}

sub theme_ui_buttons_end {
    return "</div>\n";
}

sub theme_ui_post_header {
    my ($text) = @_;
    my $rv;
    $rv .= "<center class='ui_post_header'><font size=+1>$text</font></center>\n" if (defined($text));
    if (!$tconfig{'nohr'} && !$tconfig{'notophr'}) {
    	$rv .= "<hr id='post_header_hr'>\n";
	}
    return $rv;
}

sub theme_header {
}

sub theme_ui_print_header {
    &header();
#    print "{'data': 'unbuffered'}";
    my @args = @_;
    print $args[11] if ($args[11]);
    # use Data::Dumper;
    # print Dumper(@args);
    my $hostname = &get_display_hostname();
    my $version = &get_webmin_version();
    my $prebody = $tconfig{'prebody'};
    if ($prebody) {
    	$prebody =~ s/%HOSTNAME%/$hostname/g;
    	$prebody =~ s/%VERSION%/$version/g;
    	$prebody =~ s/%USER%/$remote_user/g;
    	$prebody =~ s/%OS%/$os_type $os_version/g;
    	print "$prebody\n";
	}
	print "<table class='header' width=100%><tr>\n";
	if ($gconfig{'sysinfo'} == 2 && $remote_user) {
		print "<td id='headln1' colspan=3 align=center>\n";
		print &get_html_status_line(1);
		print "</td></tr> <tr>\n";
	}
	print "<td id='headln2l' width=15% valign=top align=left>";
	print "<div class='btn-group'>";
	if ($ENV{'HTTP_WEBMIN_SERVERS'} && !$tconfig{'framed'}) {
		print "<a href='$ENV{'HTTP_WEBMIN_SERVERS'}'>",
		      "$text{'header_servers'}</a><br>\n";
	}
	if (!$_[6] && !$tconfig{'noindex'}) {
		my @avail = &get_available_module_infos(1);
		my $nolo = $ENV{'ANONYMOUS_USER'} ||
			      $ENV{'SSL_USER'} || $ENV{'LOCAL_USER'} ||
			      $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;
		if ($gconfig{'gotoone'} && $main::session_id && @avail == 1 &&
		    !$nolo) {
			print "<a href='$gconfig{'webprefix'}/session_login.cgi?logout=1'>",
			      "$text{'main_logout'}</a><br>";
		}
		elsif ($gconfig{'gotoone'} && @avail == 1 && !$nolo) {
			print "<a href=$gconfig{'webprefix'}/switch_user.cgi>",
			      "$text{'main_switch'}</a><br>";
		}
		elsif (!$gconfig{'gotoone'} || @avail > 1) {
			print "<a href='$gconfig{'webprefix'}/?cat=",
			      $this_module_info{'category'},
			      "'>$text{'header_webmin'}</a><br>\n";
		}
	}
	if (!$_[5] && !$tconfig{'nomoduleindex'}) {
		my $idx = $this_module_info{'index_link'};
		my $mi = $module_index_link || "/".&get_module_name()."/$idx";
		my $mt = $module_index_name || $text{'header_module'};
		print "<a class='btn btn-primary btn-sm' href=\"$gconfig{'webprefix'}$mi\">\
		<i class='fa fa-arrow-left'></i> $mt</a>";
	}
	if (ref($_[3]) eq "ARRAY" && !$ENV{'ANONYMOUS_USER'} &&
	    !$tconfig{'nohelp'}) {
		print &hlink($text{'header_help'}, $_[3]->[0], $_[3]->[1]),
		      "<br>\n";
	}
	elsif (defined($_[3]) && !$ENV{'ANONYMOUS_USER'} &&
	       !$tconfig{'nohelp'}) {
		print &hlink($text{'header_help'}, $_[3]);
	}
	if ($_[4]) {
		my %access = &get_module_acl();
		if (!$access{'noconfig'} && !$config{'noprefs'}) {
			my $cprog = $user_module_config_directory ?
					"uconfig.cgi" : "config.cgi";
			print "<a class='ajax btn btn-warning btn-sm' href=\"$gconfig{'webprefix'}/$cprog?",
			      &get_module_name()."\"><i class='fa fa-gears'></i> ",
			      $text{'header_config'},"</a>";
		}
	}
	print "</div>";
	print "</td>\n";
	if ($_[2]) {
		# Title is a single image
		print "<td id='headln2c' align=center width=70%>",
		      "<img alt=\"$_[0]\" src=\"$prefix_uri/$_[1]\"></td>\n";
	}
	else {
		# Title is just text
		my $ts = defined($tconfig{'titlesize'}) ?
				$tconfig{'titlesize'} : "+2";
		print "<td id='headln2c' align=center width=70%>",
		      ($ts ? "<font size=$ts>" : ""),$_[1],
		      ($ts ? "</font>" : "");
		print "<br>$_[10]\n" if ($_[10]);
		print "</td>\n";
	}
	print "<td id='headln2r' width=15% valign=top align=right>";
	print $_[7];
	print "</td></tr></table>\n";
    print &ui_post_header($_[0]);
}

sub theme_ui_print_unbuffered_header {
    my @args = @_;
    $| = 1;
    $theme_no_table = 1;
    $args[9] .= " " if ($args[9]);
    $args[9] .= " data-pagescroll=true";
    $args[11] = '<i data="unbuffered"></i>';
    &ui_print_header(@args);
}

sub theme_ui_print_footer {
    my @args = @_;
    print &ui_pre_footer();
    &footer(@args);
}

sub theme_ui_pre_footer {
    my $rv;
    if (!$tconfig{'nohr'} && !$tconfig{'nobottomhr'}) {
    	$rv .= "<hr class='pre_footer_hr'>\n";
	}
    return $rv;
}

sub theme_footer {
    $miniserv::page_capture = 0;
    print "<div>";
    for(my $i=0; $i+1<@_; $i+=2) {
    	my $url = $_[$i];
    	if ($url ne '/' || !$tconfig{'noindex'}) {
    		if ($url eq '/') {
    			$url = "/?cat=$this_module_info{'category'}";
			}
    		elsif ($url eq '' && &get_module_name()) {
    			$url = "/".&get_module_name()."/".
    			       $this_module_info{'index_link'};
			}
    		elsif ($url =~ /^\?/ && &get_module_name()) {
    			$url = "/".&get_module_name()."/$url";
			}
    		$url = "$gconfig{'webprefix'}$url" if ($url =~ /^\//);
    		print "<a class='btn btn-primary btn-sm' href=\"$url\">",&text('main_return', $_[$i+1]),"</a>\n";
		}
	}
    print "</div>\n";
}

sub theme_ui_config_link {
    my ($text, $subs) = @_;
    my @subs = map { $_ || "../config.cgi?$module_name" }
    		  ($subs ? @$subs : ( undef ));
    return "<p>".&text($text, @subs)."<p>\n";
}

sub theme_icons_table {
    my $need_tr;
    my $cols = $_[3] ? $_[3] : 4;
#    my $per = int(100.0 / $cols);
#    print "<table class='icons_table' width=100% cellpadding=5>\n";
    print "<div class='icons-table'>";
    for(my $i=0; $i<@{$_[0]}; $i++) {
    	print "<div class='col-md-3 text-center'>\n";
    	&generate_icon($_[2]->[$i], $_[1]->[$i], $_[0]->[$i],
    		       ref($_[4]) ? $_[4]->[$i] : $_[4], $_[5], $_[6],
    		       $_[7]->[$i], $_[8]->[$i]);
    	print "</div>\n";
    }
    print "</div>";
}

sub theme_generate_icon {
    my $w = !defined($_[4]) ? "width=48" : $_[4] ? "width=$_[4]" : "";
    my $h = !defined($_[5]) ? "height=48" : $_[5] ? "height=$_[5]" : "";
    if ($tconfig{'noicons'}) {
        if ($_[2]) {
            print "$_[6]<a href=\"$prefix_uri/$_[2]\" $_[3]>$_[1]</a>$_[7]\n";
		}
        else {
            print "$_[6]$_[1]$_[7]\n";
		}
	}
    elsif ($_[2]) {
    	print "<a href=\"$prefix_uri/$_[2]\" $_[3]><img src=\"$prefix_uri/$_[0]\" alt=\"\" $w $h><br>";
    	print "$_[6]$_[1]</a>$_[7]\n";
	}
    else {
    	print "<img src=\"$prefix_uri/$_[0]\" alt=\"\" $w $h><br>",
    	      "$_[6]$_[1]$_[7]\n";
	}
}

sub theme_hlink {
    my $mod = $_[2] ? $_[2] : &get_module_name();
    my $width = $_[3] || $tconfig{'help_width'} || $gconfig{'help_width'} || 600;
    my $height = $_[4] || $tconfig{'help_height'} || $gconfig{'help_height'} || 400;
    return "<a class='help btn btn-info btn-sm' href=\"$gconfig{'webprefix'}/help.cgi/$mod/$_[1]\">\
    <i class='fa fa-question'></i> $_[0]</a>";
}

sub theme_ui_links_row {
    my ($links) = @_;
    my $rv;
    $rv = "<ul class='list-inline'>";
    foreach $link(@$links) {
        $rv .= "<li>$link</li>";
    }
    $rv .= "</ul>";
    return $rv;
}

sub theme_ui_buttons_row {
    my ($script, $label, $desc, $hiddens, $after, $before) = @_;
    my $module_name = &get_module_name();
    if (ref($hiddens)) {
    	$hiddens = join("\n", map { &ui_hidden(@$_) } @$hiddens);
	}
    return "<form action='/$module_name/$script' class='ui_buttons_form'>\n".
           $hiddens.
           &ui_submit($label).($after ? " ".$after : ""). #"</td>\n".
            $desc.
           "</form>\n";
}

sub theme_ui_form_end {
    $ui_formcount++;
    my ($buttons, $width, $nojs) = @_;
    my $rv;
    if ($buttons && @$buttons) {
    	$rv .= "<div class='btn-group'>\n";
    	my $b;
    	foreach $b (@$buttons) {
    		if (ref($b)) {
                $rv .= &ui_submit($b->[1], $b->[0], $b->[3], $b->[4]).
    			       ($b->[2] ? " ".$b->[2] : "")."\n";
			}
            elsif ($b) {
                $rv .= "$b\n";
			}
        }
        $rv .= "</div>";
	}
    $rv .= "</form>\n";
    return $rv;
}

sub theme_ui_grid_table {
    my ($elements, $cols, $width, $tds, $tabletags, $title) = @_;
    return "" if (!@$elements);
    my $rv = "<table class='ui_grid_table table table-condensed table-stripped'".
    	    ($width ? " width=$width%" : "").
    	    ($tabletags ? " ".$tabletags : "").
    	    ">\n";
    my $i;
    for($i=0; $i<@$elements; $i++) {
    	$rv .= "<tr class='ui_grid_row'>" if ($i%$cols == 0);
    	$rv .= "<td ".$tds->[$i%$cols]." valign=top class='ui_grid_cell'>".
    	       $elements->[$i]."</td>\n";
    	$rv .= "</tr>" if ($i%$cols == $cols-1);
	}
    if ($i%$cols) {
    	while($i%$cols) {
    		$rv .= "<td ".$tds->[$i%$cols]." class='ui_grid_cell'>".
    		       "<br></td>\n";
    		$i++;
    		}
    	$rv .= "</tr>\n";
    	}
    $rv .= "</table>\n";
    if (defined($title)) {
    	$rv = "<table class='ui_table table table-stripped table-condensed table-hover' ".
    	      ($width ? " width=$width%" : "").">\n".
    	      ($title ? "<tr><td><b>$title</b></td></tr>\n" : "").
                  "<tr><td>$rv</td></tr>\n".
    	      "</table>";
	}
    return $rv;
}

sub theme_ui_subheading {
    return "<h3 class='ui_subheading text-center'>".join("", @_)."</h3>\n";
}

sub theme_select_all_link {
    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selall'};
    return "<a class='select_all btn btn-primary btn-xs' onClick='var ff = document.forms[$form].$field; ff.checked = true; for(i=0; i<ff.length; i++) { if (!ff[i].disabled) { ff[i].checked = true; } } return false'>$text</a>";
}

sub theme_select_invert_link {
    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selinv'};
    return "<a class='select_invert btn btn-primary btn-xs' onClick='var ff = document.forms[$form].$field; ff.checked = !ff.checked; for(i=0; i<ff.length; i++) { if (!ff[i].disabled) { ff[i].checked = !ff[i].checked; } } return false'>$text</a>";
}

sub theme_select_rows_link {
    my ($field, $form, $text, $rows) = @_;
    $form = int($form);
    my $js = "var sel = { ".join(",", map { "\"".&quote_escape($_)."\":1" } @$rows)." }; ";
    $js .= "for(var i=0; i<document.forms[$form].${field}.length; i++) { var r = document.forms[$form].${field}[i]; r.checked = sel[r.value]; } ";
    $js .= "return false;";
    return "<a class='btn btn-primary btn-xs' onClick='$js'>$text</a>";
}

sub theme_ui_opt_textbox {
    my ($name, $value, $size, $opt1, $opt2, $dis, $extra, $max, $tags) = @_;
    my $dis1 = &js_disable_inputs([ $name, @$extra ], [ ]);
    my $dis2 = &js_disable_inputs([ ], [ $name, @$extra ]);
    my $rv;
    $size = &ui_max_text_width($size);
    $rv .= &ui_radio($name."_def", $value eq '' ? 1 : 0,
    		 [ [ 1, $opt1, "onClick='$dis1'" ],
    		   [ 0, $opt2 || " ", "onClick='$dis2'" ] ], $dis)."\n";
    $rv .= "<input class='ui_opt_textbox form-control input-sm' type='text' ".
           "name=\"".&quote_escape($name)."\" ".
           "id=\"".&quote_escape($name)."\" ".
           "size=$size value=\"".&quote_escape($value)."\"".
           ($dis ? " disabled=true" : "").
           ($max ? " maxlength=$max" : "").
           ($tags ? " ".$tags : "").">";
    return $rv;
}

sub theme_ui_hidden_start {
    my ($title, $name, $status, $url) = @_;
    my $rv;
    my $divid = "hiddendiv_$name";
    my $openerid = "hiddenopener_$name";
    my $defimg = $status ? "open.gif" : "closed.gif";
    my $defclass = $status ? 'opener_shown' : 'opener_hidden';
    my $visible = %status ? 'in' : '';
    $rv .= "<div class='panel panel-default'>";
    $rv .= "<div class='panel-heading'>";
    $rv .= "<h4 class='panel-title'>";
    $rv .= "<a data-toggle='collapse' href='#$divid'>$title</a>";
    $rv .= "</h4>";
    $rv .= "</div>";
    $rv .= "<div id='$divid' class='panel-collapse collapse $visible'>";
    $rv .= "<div class='panel-body'>";
    return $rv;
}

sub theme_ui_hidden_end {
    return "</div></div></div>\n";
}

sub theme_ui_hidden_table_start {
    my ($heading, $tabletags, $cols, $name, $status, $tds, $rightheading) = @_;
    my $rv;
    my $divid = "hiddendiv_$name";
    my $openerid = "hiddenopener_$name";
    my $defimg = $status ? "open.gif" : "closed.gif";
    my $defclass = $status ? 'opener_shown' : 'opener_hidden';
    $rv .= "<div class='panel panel-default'>";
    $rv .= "<div class='panel-heading'>";
    $rv .= "<h4 class='panel-title'>";
    $rv .= "<a data-toggle='collapse' href='#$divid'>$heading</a>";
    $rv .= "</h4>";
    $rv .= "</div>";
    $rv .= "<div id='$divid' class='panel-collapse collapse $visible'>";
    $rv .= "<div class='panel-body'>";
    $rv .= "<table class='ui_table table table-stripped table-condensed' $tabletags>\n";
    my $colspan = 1;
    $rv .= "<tr><td colspan=$colspan><div class='$defclass' id='$divid'><table width=100%>\n";
    $main::ui_table_cols = $cols || 4;
    $main::ui_table_pos = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

sub theme_ui_hidden_table_end {
    return "</table></div></td></tr></table></div></div></div>\n";
}

sub theme_ui_date_input {
    my ($day, $month, $year, $dayname, $monthname, $yearname, $dis) = @_;
    my $rv;
    $rv .= "<span class='ui_data'>";
    # $rv .= "<div class='input-group date'>";
    $rv .= "<input type='text' class='form-control date-time-picker' value='$day/$month/$year'\
    data-day='$dayname' data-month='$monthname' data-year='$yearname'/>";
    $rv .= &ui_hidden($dayname, $day);
    $rv .= &ui_hidden($monthname, $month);
    $rv .= &ui_hidden($yearname, $year);
    # $rv .= "<span class='input-group-addon'>";
    # $rv .= "<span class='glyphicon glyphicon-calendar'></span>";
    # $rv .= "</span>";
    # $rv .= "</div>";
    # $rv .= &ui_textbox($dayname, $day, 3, $dis);
    # $rv .= "/";
    # $rv .= &ui_select($monthname, $month,
    # 		  [ map { [ $_, $text{"smonth_$_"} ] } (1 .. 12) ],
    # 		  1, 0, 0, $dis);
    # $rv .= "/";
    # $rv .= &ui_textbox($yearname, $year, 5, $dis);
    # $rv .= "</span>";
    return $rv;
}

sub theme_date_chooser_button {
    return '';
}

sub print_template {
    $template_name = @_[0];
    if (open(my $fh, '<:encoding(UTF-8)', "$templates_path/$template_name")) {
        while (my $row = <$fh>) {
            print (eval "qq($row)");
        }
            close($fh);
    } else {
        print "$text{'error_load_template'} '$templates_path/$template_name' $!";
    }
}

sub get_right_frame_sections
{
local %sects;
&read_file($right_frame_sections_file, \%sects);
if ($sects{'global'}) {
	# Force use of global settings
	return \%sects;
	}
else {
	# Can try personal settings, but fall back to global
	local %usersects;
	if (&read_file($right_frame_sections_file.".".$remote_user,
		       \%usersects)) {
		return \%usersects;
		}
	else {
		return \%sects;
		}
	}
}

sub list_virtualmin_domains {
    my $rv = '';
    if (@doms) {
#        $rv.= 'lolo ';
    	# Show Virtualmin servers this user can edit, plus links for various
    	# functions within each
#    	$rv .= "<div class='domainmenu'>\n";
#    	$rv .= &ui_hidden("mode", $mode);
    	if ($virtual_server::config{'display_max'} &&
    	    @doms > $virtual_server::config{'display_max'}) {
    		# Show text field for domain name
    		$rv.= $text{'left_dname'};
    		$rv.= &ui_textbox("dname", $d ? $d->{'dom'} : $in{'dname'}, 15);
		}
    	else {
    		# Show menu of domains
            my $sel;
            if (-r "$root_directory/virtual-server/summary_domain.cgi") {
                $sel = "; window.parent.frames[1].location = ".
                       "\"virtual-server/summary_domain.cgi?dom=\"+this.value";
			}
#            $rv.= "<form class='navbar-form navbar-left'>";
#            $rv.= "<div class='form-group'>";
    		$rv.= &ui_select("dom", $did,
    			[ map { [ $_->{'id'},
    				  ("&nbsp;&nbsp;" x $_->{'indent'}).
    				  &virtual_server::shorten_domain_name($_),
    				  $_->{'disabled'} ?
    					"style='font-style:italic'" : "" ] }
    			      @doms ],
    			1, 0, 0, 0,
    # 			"onChange='form.submit() $sel'".
    # 			"style='width:$selwidth'");
#    			"onChange=\"\$('.vlink').data('domain', '123')\"");
    			);
#            $rv.= "</div>";#</form>"
		}
#    	$rv .= "<input type='image' src='images/ok.gif' alt='' class='goArrow'>\n";
    	foreach $a (@admincats) {
    		$rv.= &ui_hidden($a, 1),"\n" if ($in{$a});
		}
#    	$rv .= "</div>\n";
        $rv.= '<ul class="nav navbar-nav"><li class="dropdown">'.
        '<a data-hover="dropdown" data-toggle="dropdown" class="dropdown-toggle" aria-expanded="false">VServer</a>'.
        '<ul class="dropdown-menu">';
    	if (!$d) {
    		if ($in{'dname'}) {
    			$rv .= "\n";
			}
		}
    
    	# Show domain creation link, if possible
    	if (&virtual_server::can_create_master_servers() ||
    	    &virtual_server::can_create_sub_servers()) {
    		($rdleft, $rdreason, $rdmax) =
    			&virtual_server::count_domains("realdoms");
                    ($adleft, $adreason, $admax) =
    			&virtual_server::count_domains("aliasdoms");
    		if ($rdleft || $adleft) {
    			$rv.= &print_virtualmin_link(
    				{ 'url' => "virtual-server/domain_form.cgi?".
    					   "generic=1&amp;gparent=$d->{'id'}",
    				  'title' => $vserver_lang{'form_title'} },
    				'leftlink', $d);
			}
    		else {
#    			$rv .= "<div class='leftlink'><b>",
#    			      &text('left_nomore'),"</b></div>\n";
			}
		}
    
    	if (!$d) {
    		goto nodomain;
		}
    
    	# Get actions and menus from Virtualmin
    	@buts = &virtual_server::get_all_domain_links($d);
    
    	# Show 'objects' category actions at top level
    	my @incat = grep { $_->{'cat'} eq 'objects' } @buts;
    	foreach my $b (@incat) {
    		$rv.= &print_virtualmin_link($b, 'leftlink');
		}
    
    	# Show others by category (except those for creation, which appear
    	# at the top)
    	my @cats = &unique(map { $_->{'cat'} } @buts);
    	foreach my $c (@cats) {
    		next if ($c eq 'objects' || $c eq 'create');
    		my @incat = grep { $_->{'cat'} eq $c } @buts;
    		$rv .= &print_category_opener("cat_$c", \@cats,
    				       $incat[0]->{'catname'});
#    		$rv .= "<div class='itemhidden' id='cat_$c'>\n";
    		my @incatsort = grep { !$_->{'nosort'} } @incat;
    		if (@incatsort) {
    			@incat = sort { ($a->{'title'} || $a->{'desc'}) cmp
                                            ($b->{'title'} || $b->{'desc'})} @incat;
			}
    		foreach my $b (@incat) {
    			$rv.= &print_virtualmin_link($b, "linkindented");
			}
			$rv.= "</ul></li>";
#    		$rv .= "</div>\n";
		}
    
#    	$rv .= "<table width='100%' border='0'>
#      <tr><td><hr></td></tr>
#      <tr><td>Global Virtualmin Setup</td></tr>
#      <tr><td><hr></td></tr>
#    </table>\n";
    	nodomain:
    	$rv.='</ul></li></ul>';
	}
    elsif ($mode eq "virtualmin") {
    	# No domains
#    	$rv .= "<div class='leftlink'>";
    	if (@alldoms) {
    		$rv .= $text{'left_noaccess'};
		}
    	else {
    		$rv .= $text{'left_nodoms'};
		}
#    	$rv .= "</div>\n";
    
    	# Show domain creation link
    	if (&virtual_server::can_create_master_servers() ||
    	    &virtual_server::can_create_sub_servers()) {
    # 		$rv .= "<div class='leftlink'><a href='virtual-server/domain_form.cgi?generic=1' target=right>$text{'left_generic'}</a></div>\n";
    		$rv .= "<a href='virtual-server/domain_form.cgi?generic=1' target=right>$text{'left_generic'}</a>\n";
		}
	}
    elsif ($mode eq "vm2" && @servers) {
    	# Show managed servers
#    	$rv .= "<div class='domainmenu'>\n";
    	$rv .= &ui_hidden("mode", $mode);
    	$rv .= &ui_select("sid", $sid,
    		[ map { [ $_->{'id'}, ("&nbsp;&nbsp;" x $_->{'indent'}).
    				      &shorten_hostname($_) ] } @servers ],
    		1, 0, 0, 0,
    		"onChange='form.submit()' style='width:$selwidth'");
    	$rv .= "<input type='image' src='images/ok.gif' alt='' class='goArrow'>\n";
#    	$rv .= "</div>\n";
	}
    elsif ($mode eq "vm2") {
    	# No servers
#    	$rv .= "<div class='leftlink'>";
    	if (@allservers) {
    		$rv .= $text{'left_novm2access'};
		}
    	else {
    		$rv .= $text{'left_novm2'};
		}
#    	$rv .= "</div>\n";
	}
	return $rv;
}

sub print_virtualmin_link {
    my $rv = '';
    local ($l, $cls, $icon, $d) = @_;
    local $t = $l->{'target'} || "right";
    if ($icon) {
#    	$rv.= "<div class='linkwithicon'><img src='images/$l->{'icon'}.png' alt=''>\n";
	}
#    $rv.= "<div class='$cls'>";
    $rv.= "<b>" if ($l->{'icon'} eq 'index');
    $rv.= "<li><a class='ajax vlink' data-domain='$d' href='$l->{'url'}'>$l->{'title'}</a></li>";
    $rv.= "</b>" if ($l->{'icon'} eq 'index');
#    $rv.= "</div>";
    if ($icon) {
#    	$rv.= "</div>";
	}
    $rv.= "\n";
    return $rv;
}

sub print_category_opener {
    my $rv = '';
    local ($c, $cats, $label, $d) = @_;
    local @others = grep { $_ ne $c } @$cats;
    local $others = join("&", map { $_."=".$in{$_} } @others);
    $others = "&$others" if ($others);
    $others .= "&amp;dom=$did";
    $others .= "&amp;mode=$mode";
    $label = $c eq "others" ? $text{'left_others'} : $label;
    
    # Show link to close or open catgory
#    $rv.= "<div class='linkwithicon'>";
#    $rv.= "<a href=\"javascript:toggleview('$c','toggle$c')\" id='toggle$c'><img border='0' src='images/closed.gif' alt='[+]'></a>\n";
#    $rv.= "<div class='aftericon'><a href=\"javascript:toggleview('$c','toggle$c')\" id='toggletext$c'><font color='#000000'>$label</font></a></div></div>\n";
    $rv.= "<li class='dropdown-submenu'><a>$label</a><ul class='dropdown-menu'>";
    return $rv;
}

