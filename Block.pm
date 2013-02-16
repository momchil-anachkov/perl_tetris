package Block;
use Moose;
use Wx;
use Colors;

=comment
Boolean flag indicating whether the block is filled (with a mino).
=cut
has filled => (
    is => 'ro',
    isa => 'Bool',
    reader => 'is_filled',
    writer => '_fill',
    builder => '_build_filled',
);

=comment
Boolean flag indicating whether the block is stacked (part of the board stack).
=cut
has stacked => (
    is => 'rw',
    isa => 'Bool',
    reader => 'is_stacked',
    writer => 'stack',
    builder => '_build_stacked'
);

=comment
The color of the block.
=cut
has color => (
    is => 'ro',
    isa => 'Wx::Colour',
    writer => '_set_color',
    builder => '_build_color'
);

sub _build_filled () {
    return 0;
}

sub _build_stacked () {
    return 0;
}

sub _build_color () {
    return Wx::Colour->new(&Colors::block_default);
}

=comment
Fills the block and sets its color to the one of the passed mino.
=cut
sub fill {
    my ($self, $filling, $mino) = @_;
    
    $self->_fill($filling);
    $self->_set_color($mino->color) if defined $mino;
}

1;