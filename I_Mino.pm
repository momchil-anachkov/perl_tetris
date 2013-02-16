package I_Mino;
use Moose;
use Colors;
use Data::Dumper;

extends qw(Mino);

sub _init_rot_positions () {
    my $positions = [
        [
            [0,0],      
            [0,1],     
            [0,2],
            [0,-1],
        ],
        [
            [0,0],
            [-1,0],
            [-2,0],
            [1,0],
        ],
        [
            [0,0],
            [0,-1],
            [0,-2],
            [0,1],
        ],
        [
            [0,0],
            [1,0],
            [2,0],
            [-1,0],
        ],
    ];
}

sub _build_color () {
    Wx::Colour->new(&Colors::i_mino);
}

1;