package Mino;
use Moose;
use Wx;
use Data::Dumper;
use Clone qw(clone);

=comment
X coordinate of the pivot bliock of the mino.
=cut
has x => (
    is => 'rw',
    isa => 'Int',
    reader => 'x',
    writer => 'set_x',
    required => 1,
);

=comment
Y coordinate of the pivot bliock of the mino.
=cut
has y => (
    is => 'rw',
    isa => 'Int',
    reader => 'y',
    writer => 'set_y',
    required => 1,
);

=comment
Mino color.
=cut
has color => (
    is => 'ro',
    isa => 'Wx::Colour',
    builder => '_build_color',
);

=comment
Current rotation.
Varies between 0 and 3.
Index for the _rot_positions.
=cut
has rotation => (
    is => 'rw',
    isa => 'Int',
    reader => 'rotation',
    writer => 'set_rotation',
    builder => '_init_rotation',
);

=comment
Pre-Defined rotation positions.
=cut
has _rot_positions => (
    is => 'bare',
    reader => '_rot_positions',
    isa => 'ArrayRef[ArrayRef[ArrayRef[Int]]]',
    builder => '_init_rot_positions',
);

=comment
Pre-Defined rotation positions.
=cut
sub move_left () {
    my $self = shift;
    $self->set_x($self->x-1);
}

=comment
Moves the mino right one block.
=cut
sub move_right () {
    my $self = shift;
    $self->set_x($self->x+1);
}

=comment
Moves the mino down one block.
=cut
sub fall () {
    my $self = shift;
    $self->set_y($self->y+1);
}

=comment
Moves the mino up one block.
=cut
sub move_up () {
    my $self = shift;
    $self->set_y($self->y-1);
}

=comment
Rotates the mino clockwise.
=cut
sub rotate_c () {
    my $self = shift;
    $self->set_rotation(($self->rotation+1) % 4);
}

=comment
Rotates the mino counter-clockwise.
=cut
sub rotate_cc () {
    my $self = shift;
    $self->set_rotation(($self->rotation-1) % 4);
}

=comment
Used to get the absolute coordinates of the mino.
=cut
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

=comment
Defines the rotations array for the mino.
See a concrete subclass.
=cut
sub _init_rot_positions () {
    confess(qq["_init_rot_positions" must be implemented by a subclass!]);
}

=comment
Defines the color for the mino.
See a concrete subclass.
=cut
sub _build_color () {
    confess(qq["_build_color" must be implemented by a subclass!]);
}

1;