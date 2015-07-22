#!/usr/bin/perl -w
use strict;
use Curses::UI;

my @headlines    = ( "Printing Options", "E-Mail Options" );
my @printOptions = ( "Reset Print Quota");
my @emailOptions = ( "Create E-Mail Account", "Change Password");
my $mainWindowTitle = "ECC Menu";
my $helpText        = "For Focus on File: Ctrl-X, TAB or ESC\nShortcuts: Ctrl-Q to Exit\n           Ctrl-H for Documention\n";

# Window Names
my $mainWindowName = "MainWindow";
my $emailWindowName = "EmailWindow";
my $printWindowName = "PrintWindow";
my $prevWindow      = "MainWin";

my $cui;
my $emailInitialized = 0;
my $printInitialized = 0;

# UI Dialogs
sub exit_dialog {
	my $return = $cui->dialog(
		-message => "Do you really want to quit?",
		-title   => "Are you sure?",
		-buttons => [ 'yes', 'no' ],

	);
	exit(0) if $return;
}

sub help_dialog {
	my $helpDialog = $cui->dialog($helpText);
}

# UI Functions
sub draw_print {
	$prevWindow = "$mainWindowName";
	my $win        = $cui->add( "$printWindowName", "Window", -border => 1, -y => 2, -bg => "blue", -title => "Printing Options" );
	my $max_height = $win->height();
	my $max_width  = $win->width();
	my $listBox    = $win->add( "PrintList", "Listbox", -fg => "white", -height => $max_height, -border => 1 );

	$listBox->onChange(
		sub {
			my $id = $listBox->get_active_id();
		}
	);
	
	$listBox->values( \@printOptions );
	$listBox->focus();
	$printInitialized = 1;
}

sub draw_email {
	$prevWindow = "$mainWindowName";
	my $win        = $cui->add( "$emailWindowName", "Window", -border => 1, -y => 2, -bg => "blue", -title => "E-Mail Options" );
	my $max_height = $win->height();
	my $max_width  = $win->width();
	my $listBox    = $win->add( "EmailList", "Listbox", -fg => "white", -height => $max_height, -border => 1 );

	$listBox->onChange(
		sub {
			my $id = $listBox->get_active_id();
		}
	);

	$listBox->values( \@emailOptions );
	$listBox->focus();
	$emailInitialized = 1;
}

sub draw_main {
	my $win        = $cui->add( "$mainWindowName", "Window", -border => 1, -y => 2, -bg => "blue", -title => $mainWindowTitle );
	my $max_height = $win->height();
	my $max_width  = $win->width();
	my $listBox    = $win->add( "mainList", "Listbox", -fg => "white", -height => $max_height, -border => 1 );
	my $fileMenu   = [
		{
			-label => 'Exit     Ctrl-Q',
			-value => sub { exit_dialog() }
		},
	];
	my $helpMenu = [
		{
			-label => 'Documentation     Ctrl-H',
			-value => sub { help_dialog() }
		},
	];
	my $menu = [ { -label => 'File', -submenu => $fileMenu }, { -label => 'Help', -submenu => $helpMenu }, ];
	$cui->add( 'fileMenu', 'Menubar', -menu => $menu, -fg => "white", -bg => "black", );

	$listBox->onChange(
		sub {
			my $id = $listBox->get_active_id();
			if ( 0 == $id ) {
				if ( 0 == $printInitialized ) {
					draw_print();
				}
				else {
					shift()->root->focus("$printWindowName");	
				}
			}
			elsif ( 1 == $id ) {
				if ( 0 == $emailInitialized ) {
					draw_email();
				}
				else {
					shift()->root->focus("$emailWindowName");
				}
			}
		}
	);

	# Menu focus for Ctrl-X, ESC and TAB
	$cui->set_binding( sub { shift()->root->focus('fileMenu') }, "\e" );
	$cui->set_binding( sub { shift()->root->focus('fileMenu') }, "\t" );

	# Shortcut Ctrl-Q to exit and Ctrl-H for Help.
	$cui->set_binding( sub { exit_dialog(); },                       "\cQ" );
	$cui->set_binding( sub { help_dialog(); },                       "\cH" );
	$cui->set_binding( sub { shift()->root->focus("$prevWindow"); }, "\cX" );

	$listBox->values( \@headlines );
	$listBox->focus();

	$cui->mainloop();
}

# Initialize
sub initialize() {
	$cui = new Curses::UI( -color_support => 1 );
	draw_main();
}

initialize();

