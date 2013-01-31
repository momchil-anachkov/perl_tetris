#!/usr/bin/perl -w

package Tetris;
use MooseX::NonMoose;
use Wx;
use Moose;
use Game;

use Board_Panel;

extends qw(Wx::App);

sub OnInit () {
    my $main_frame = Wx::Frame->new( undef,              # parent window
                                -1,                 # Default ID
                                'Tetris',           # title
                                [-1, -1],           # default position
                                [700, 800],         # size
                                &Wx::wxDEFAULT_FRAME_STYLE & ~(&Wx::wxRESIZE_BORDER | &Wx::wxMAXIMIZE_BOX), #prevent resizing.
                               );
    
    #Testing some menu crap.
    my $menu_bar = Wx::MenuBar->new();
    my $first_menu = Wx::Menu->new();
    my $menu_item = Wx::MenuItem->new($first_menu, -1, "Test 2");
    $first_menu->Append($menu_item);
    $menu_bar->Append($first_menu, "Test");
    $main_frame->SetMenuBar($menu_bar);
    
    my $game = Game->new();
    my $game_panel = $game->get_panel();
    $game_panel->Create($main_frame, 123);
    
    $game->get_cells();
    
    $main_frame->Show(1);
    
    $game->start();

    
    #my $board = Board_Panel->new($main_frame, 123, game => $game);
    #my $board = Board_Panel->new(game => $game);
    
}

1;