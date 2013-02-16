#!/usr/bin/perl -w

package Tetris;

use Moose;
use MooseX::NonMoose;
extends qw(Wx::App);

use Wx;
use Wx::Event qw(EVT_MENU);
use Game;
use Board_Panel;
use Score_Panel;

has game => (
    is => 'rw',
    isa => 'Game',
    reader => 'game',
	writer => 'set_game',
);

use Data::Dumper;

sub BUILD () {
    my $self = shift;
    EVT_MENU($self, 1, \&start);
    EVT_MENU($self, 2, \&pause);
    EVT_MENU($self, 3, \&stop);
}

sub start () {
    my $self = shift;
    my $evt = shift;
    
    $self->enable_menu_items(0,1,1);
    $self->game->start;
}

sub pause () {
    my $self = shift;
    my $evt = shift;
    
    $self->enable_menu_items(0,1,1);
    $self->game->pause;
}

sub stop () {
    my $self = shift;
    my $evt = shift;
    
    $self->enable_menu_items(1,0,0);
    $self->game->game_over;
}

sub enable_menu_items ($$$) {
    my ($self, $start_enabled, $pause_enabled, $stop_enabled) = @_;
    
    #Dig deep to get the game menu.
    my $frame = $self->GetTopWindow;
    my $menubar = $frame->GetMenuBar();
    my $menu = $menubar->GetMenu(0);
    
    if ($pause_enabled) {
        $menu->SetLabel(2, 'Continue') if $self->game->state eq &Game::RUNNING;
        $menu->SetLabel(2, 'Pause') if $self->game->state eq &Game::PAUSED; 
    }
    
    $menu->Enable(1, $start_enabled);
    $menu->Enable(2, $pause_enabled);
    $menu->Enable(3, $stop_enabled);
}

sub OnInit () {
    my $self = shift;
    
    my $main_frame = Wx::Frame->new(
        undef,              # parent window
        -1,                 # Default ID
        'Tetris',           # title
        [-1, -1],           # default position
        [800, 800],         # size
        &Wx::wxDEFAULT_FRAME_STYLE & ~(&Wx::wxRESIZE_BORDER | &Wx::wxMAXIMIZE_BOX), #prevent resizing.
    );
    
    #Create the menu bar and the game menu.
    my $menu_bar = Wx::MenuBar->new();
    my $game_menu = Wx::Menu->new();
    
    #Add the menu items to the game menu.
    $game_menu->Append(1, 'Start');
    $game_menu->Append(2, 'Pause');
    $game_menu->Append(3, 'Stop');
    
    #Add the game menu and the menu bar to the frame.
    $menu_bar->Append($game_menu, "Game");
    $main_frame->SetMenuBar($menu_bar);
    
    $game_menu->Enable(1, 1);
    $game_menu->Enable(2, 0);
    $game_menu->Enable(3, 0);
    
    my $board = Board_Panel->new();
    $board->Create(
        $main_frame,                #Parent window
        -1,                         #ID
        &Wx::wxDefaultPosition,     #Position
        Wx::Size->new(400,800),     #Size
        &Wx::wxWANTS_CHARS          #Style
    );
    
    my $score_panel = Score_Panel->new();
    $score_panel->Create(
        $main_frame,                #Parent window
        -1,                         #ID
        &Wx::wxDefaultPosition,     #Position
        Wx::Size->new(200,800),     #Size
        &Wx::wxWANTS_CHARS          #Style
    );
    
    my $game = Game->new(
        'app' => $self,
        'score_panel' => $score_panel,
        'board_panel' => $board,
    );
    $self->set_game($game);
    
    my $sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    
    my $queue_panel = Wx::Panel->new(
        $main_frame,                #Parent window
        -1,                         #ID
        &Wx::wxDefaultPosition,     #Position
        Wx::Size->new(200,800),     #Size
        &Wx::wxWANTS_CHARS          #Style
    );
    
    $sizer->Add($score_panel, 2, &Wx::wxFIXED_MINSIZE);
    $sizer->Add($board, 4, &Wx::wxFIXED_MINSIZE);
    $sizer->Add($queue_panel, 2, &Wx::wxFIXED_MINSIZE);
    
    $main_frame->SetSizer($sizer);
    $main_frame->Show(1);
}

1;