package Mino;
use Moose;
use Data::Dumper;
use Clone qw(clone);

has x => (
    is => 'rw',
    isa => 'Int',
    reader => 'x',
    writer => 'set_x',
    required => 1,
);

has y => (
    is => 'rw',
    isa => 'Int',
    reader => 'y',
    writer => 'set_y',
    required => 1,
);

has rotation => (
    is => 'rw',
    isa => 'Int',
    reader => 'rotation',
    writer => 'set_rotation',
    builder => '_init_rotation',
);

has _rot_positions => (
    is => 'bare',
    reader => '_rot_positions',
    isa => 'ArrayRef[ArrayRef[ArrayRef[Int]]]',
    builder => '_init_rot_positions',
);

sub move_left () {
    my $self = shift;
    $self->set_x($self->x-1);
}

sub move_right () {
    my $self = shift;
    $self->set_x($self->x+1);
}

sub fall () {
    my $self = shift;
    $self->set_y($self->y+1);
}

sub rotate () {
    my $self = shift;
    $self->set_rotation(($self->rotation+1) % 4);
}

sub get_coords () {
    my $self = shift;
    
    #Clone the structure in order not to return the same reference.
    my @coords = @{clone $self->_rot_positions->[$self->rotation]};
    
    #Calculate coordinates.
    @coords = map {
        $_->[0] += $self->x;
        $_->[1] += $self->y;
        $_;
        } @coords;
    return @coords;
}

sub _init_rotation () {
    return 0;
}

sub _init_rot_positions () {
    confess(qq["_init_rot_positions" must be implemented by a subclass!]);
}

1;