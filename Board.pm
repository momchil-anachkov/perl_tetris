package Board;
use Moose;
use Clone qw(clone);

use Block;
use L_Mino;
use J_Mino;
use S_Mino;
use Z_Mino;
use I_Mino;
use O_Mino;
use T_Mino;

use Data::Dumper;

has cells => (
    is => 'bare',
    isa => 'ArrayRef[ArrayRef[Block]]',
    reader => '_get_cells',
    writer => '_set_cells',
    builder => '_build_cells',
);

has current_mino => (
    is => 'rw',
    isa => 'Mino',
    reader => 'current_mino',
    writer => 'set_current_mino',
);
after 'set_current_mino'  => \&fill_mino_blocks;

sub get_cells () {
    my $self = shift;
    my $cells = $self->_get_cells;
    
    clone $cells;
}

sub move_mino_left () {
    shift->current_mino->move_left();
}

sub move_mino_right () {
    shift->current_mino->move_right();
}

sub move_mino_down () {
    shift->current_mino->fall();
}
before 'move_mino_down' => \&clear_mino_blocks;

sub clear_mino_blocks () {
    my $self = shift;
    
    my @cells = @{$self->_get_cells()};
    
    foreach my $row (@cells) {
        foreach my $cell (@$row) {
            $cell->set_filled(0);
        }
    }
    
    #my $self = shift;
    #
    #my @coordinates = $self->current_mino->get_coords;
    #my @cells = @{$self->_get_cells()};
    #
    ##print Dumper @cells;
    #
    ##Fill the cells.
    #foreach my $tuple (@coordinates) {
    #    my $block = @cells[$$tuple[0]]->[$$tuple[1]];
    #    $block->set_filled(0);
    #    #print Dumper @cells[$$tuple[0]]->[$$tuple[1]];
    #}
}

sub fill_mino_blocks () {
    my $self = shift;
    
    my @coordinates = $self->current_mino->get_coords;
    my @cells = @{$self->_get_cells()};
    
    #print Dumper @cells;
    
    #Fill the cells.
    foreach my $tuple (@coordinates) {
        my $block = @cells[$$tuple[0]]->[$$tuple[1]];
        $block->set_filled(1);
        #print Dumper @cells[$$tuple[0]]->[$$tuple[1]];
    }
}

sub _build_cells () {
    my @cells;
    
    foreach my $i (0..9) {
        my @rows;
        foreach my $j (0..19) {
            push (@rows, Block->new());
        }
        push (@cells, \@rows);
    }
    return \@cells;
}

1;