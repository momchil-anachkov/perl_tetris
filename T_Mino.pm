package T_Mino;
use Moose;

extends qw(Mino);

sub _init_rot_positions () {
    my $positions = [
        [
            [0,0],      
            [-1,0],     
            [0,-1],
            [1,0],
        ],
        [
            [0,0],
            [0,-1],
            [1,0],
            [0,1],
        ],
        [
            [0,0],
            [1,0],
            [0,1],
            [-1,0],
        ],
        [
            [0,0],
            [0,1],     
            [-1,0],
            [0,-1],
        ],
    ];
}

1;