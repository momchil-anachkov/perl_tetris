package Block;
use Moose;

has filled => (
    is => 'rw',
    isa => 'Bool',
    reader => 'is_filled',
    writer => 'set_filled',
    builder => '_build_filled',
);

#has x => (
#    is => 'rw',
#    isa => 'Int',
#    reader => 'x',
#    writer => 'set_x',
#    required => 1,
#);
#
#has y => (
#    is => 'rw',
#    isa => 'Int',
#    reader => 'y',
#    writer => 'set_y',
#    required => 1,
#);

sub _build_filled () {
    return 0;
}

1;