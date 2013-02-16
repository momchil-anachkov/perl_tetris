package O_Mino;
use Moose;
use Data::Dumper;

extends qw(Mino);

sub _init_rot_positions () {
    my $positions = [
        [
            [0,0],      
            [1,0],     
            [0,1],
            [1,1],
        ],
    ];
}

sub _build_color () {
    Wx::Colour->new(&Colors::o_mino);
}

sub rotate_c () {
    return 0;
}

sub rotate_cc () {
    return 0;
}

1;