package Block;
use Moose;
use Wx;
use Colors;

has filled => (
    is => 'ro',
    isa => 'Bool',
    reader => 'is_filled',
    writer => '_fill',
    builder => '_build_filled',
);

has stacked => (
    is => 'rw',
    isa => 'Bool',
    reader => 'is_stacked',
    writer => 'stack',
    builder => '_build_stacked'
);

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

sub fill {
    my ($self, $filling, $mino) = @_;
    
    $self->_fill($filling);
    $self->_set_color($mino->color) if defined $mino;
}

1;