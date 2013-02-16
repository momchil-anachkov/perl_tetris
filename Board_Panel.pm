#!/usr/bin/perl -w
use strict;

package Board_Panel;

use Wx;
use Moose;
use MooseX::NonMoose;
use Sizes;
use Wx::Event qw(EVT_PAINT EVT_KEY_UP EVT_KEY_DOWN);
use Data::Dumper;
use Colors;
extends qw(Wx::Panel);

=comment
Reference to the current game.
=cut
has game => (
    is => 'rw',
    isa => 'Game',
    reader => 'game',
	writer => 'set_game',
);

sub BUILD () {
    my $self = shift;
    
    $self->SetBackgroundColour(Wx::Colour->new(255,255,255));
    $self->Refresh();
    $self->SetBackgroundStyle(&Wx::wxBG_STYLE_CUSTOM);
    
    EVT_PAINT($self, \&paint);
    EVT_KEY_DOWN($self, \&Game::process_keypress);
}

=comment
Used to paint the board.
=cut
sub paint {
    my $self = shift;
    my $dc = Wx::BufferedPaintDC->newWindow($self);

    $dc->Clear;
    
    my @cells = $self->game->get_cells();

    #$dc->SetBrush(&Wx::wxBLUE_BRUSH);

    $dc->SetBrush(Wx::Brush->new(Wx::Colour->new( &Colors::block_default ), -1));    
    $dc->SetPen( Wx::Pen->new( Wx::Colour->new( &Colors::pen ), &Sizes::border_size, &Wx::wxSOLID) );
    
    my $block_size = &Sizes::block_size;
    my ($start_point_x, $start_point_y) = $self->GetSizeWH();
    
    for my $i (0..19) {
        for my $j (0..9) {
            $dc->SetBrush(Wx::Brush->new($cells[$i][$j]->color , -1)) if ($cells[$i][$j]->is_filled || $cells[$i][$j]->is_stacked);
            $dc->DrawRectangle( $start_point_x/17 + $block_size*$j, $start_point_y/37 + $block_size*$i, $block_size, $block_size );
            $dc->SetBrush(Wx::Brush->new(Wx::Colour->new( &Colors::block_default ), -1));
        }
    }
}
1;