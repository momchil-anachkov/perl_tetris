package Mino;
use Moose;
use Wx;
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

has color => (
    is => 'ro',
    isa => 'Wx::Colour',
    builder => '_build_color',
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

sub move_up () {
    my $self = shift;
    $self->set_y($self->y-1);
}

sub rotate_c () {
    my $self = shift;
    $self->set_rotation(($self->rotation+1) % 4);
}

sub rotate_cc () {
    my $self = shift;
    $self->set_rotation(($self->rotation-1) % 4);
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

sub is_in_range () {
    my $self = shift;
    
    foreach my $tuple ($self->get_coords) {
        return 0 if
        $$tuple[0] < 0 || $$tuple [0] > 9 ||
        $$tuple[1] < 0 || $$tuple [1] > 19;
    }
    
    return 1;
}

sub _init_rotation () {
    return 0;
}

sub _init_rot_positions () {
    confess(qq["_init_rot_positions" must be implemented by a subclass!]);
}

sub _build_color () {
    confess(qq["_build_color" must be implemented by a subclass!]);
}

1;