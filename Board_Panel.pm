#!/usr/bin/perl -w
use strict;

package Board_Panel;

use Wx;
use Moose;
use MooseX::NonMoose;
use Sizes;
use Wx::Event qw(EVT_PAINT EVT_KEY_UP);
use Data::Dumper;
extends qw(Wx::Panel);

has game => (
    is => 'bare',
    isa => 'Game',
    reader => '_game',
    required => 1,
);

sub FOREIGNBUILDARGS {    
    shift;

    #pop the last pair of arguments
    pop;
    pop;
    
    @_;
}

sub BUILD () {
    my $self = shift;
    
    $self->SetBackgroundColour(Wx::Colour->new(255,255,255));
    $self->Refresh();
    $self->SetBackgroundStyle(&Wx::wxBG_STYLE_CUSTOM);
    
    EVT_PAINT($self, \&paint);
    EVT_KEY_UP($self, \&on_key_release);
}

sub on_key_release {
    my $self = shift;
    my $evt = shift;
    
    print 'Works!';
}

sub paint {
    my $self = shift;
    my $dc = Wx::BufferedPaintDC->newWindow($self);
    #my $dc = Wx::PaintDC->new($self);
    
    #Draw some meaningless background.
    $dc->SetBrush(&Wx::wxWHITE_BRUSH);
    $dc->DrawRectangle( 0, 0, 3000, 3000 );
    
    my $cells = $self->_game->get_cells();

    $dc->SetBrush(&Wx::wxBLUE_BRUSH);
    $dc->SetPen( Wx::Pen->new( Wx::Colour->new( 100, 100, 100 ), &Sizes::border_size, &Wx::wxSOLID) );
    
    my $block_size = &Sizes::block_size;
    my ($start_point_x, $start_point_y) = $self->GetSizeWH();
    
    for my $i (0..19) {
        for my $j (0..9) {
            $dc->SetBrush(&Wx::wxRED_BRUSH) if ($cells->[$j][$i]->is_filled);
            $dc->DrawRectangle( $start_point_x/4 + $block_size*$j, $start_point_y/33 + $block_size*$i, $block_size, $block_size );
            $dc->SetBrush(&Wx::wxBLUE_BRUSH);
        }
    }
}
1;