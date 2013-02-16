package Game;
use Moose;
use MooseX::NonMoose;
use feature qw(switch);

extends qw(Wx::EvtHandler);

use Wx;
use Wx::Event qw(EVT_TIMER EVT_KEY_UP EVT_KEY_DOWN);
use Moose::Util::TypeConstraints;

#use Board;

use Score_Panel;
use Board_Panel;

use Block;
use L_Mino;
use J_Mino;
use S_Mino;
use Z_Mino;
use I_Mino;
use O_Mino;
use T_Mino;

use Data::Dumper;

use constant {
        RUNNING   => 'running',
        PAUSED   => 'paused',
        OVER   => 'over',
};

enum 'valid_state', [&RUNNING, &PAUSED, &OVER];
has state => (
    is => 'rw',
    isa => 'valid_state',
    reader => 'state',
    writer => 'set_state',
    builder => '_build_state',
);

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

has score => (
    is => 'ro',
    isa => 'Int',
    writer => '_set_score',
    builder => '_build_score',
);

has _ticker => (
    is => 'bare',
    isa => 'Wx::Timer',
    reader => '_ticker',
    builder => '_build_ticker',
);

has score_panel => (
    is => 'ro',
    isa => 'Score_Panel',
    required => 1,
);

has board_panel => (
    is => 'ro',
    isa => 'Board_Panel',
    required => 1,
);

has app => (
    is => 'bare',
    isa => 'Wx::App',
    reader => '_app',
    required =>1,
);

sub get_cells () {
    my $self = shift;
    @{$self->_get_cells()};
}

sub FOREIGNBUILDARGS {    
    shift;

    #Pop the aditional constructor arguments (App, Board_Panel, Score_Panel)
    pop;
    pop;
    pop;
    pop;
    pop;
    pop;
    
    #Pass the rest to the parent constructor.
    @_;
}

sub BUILD () {
    my $self = shift;
    
    $self->score_panel->set_game($self);
    $self->board_panel->set_game($self);
    
    EVT_TIMER($self, $self->_ticker, \&tick);
    EVT_KEY_DOWN($self, \&Game::process_keypress);
}

sub tick () {
    my $self = shift;
    my $event = shift;
    my $mino = $self->current_mino;
    
    $self->clear_mino_blocks;

    $mino->fall;
    if (!$self->move_is_valid) {
        $mino->move_up;
        $self->stack_current_mino();
        $self->clear_stacked_rows();
        $self->set_current_mino($self->generate_mino);
        
        #Game over if the newly generated mino conflicts.
        if (!$self->move_is_valid) {
            $self->game_over;
            return;
        }
    }
    
    $self->fill_mino_blocks;
    $self->board_panel->Refresh();
}

sub process_keypress {
    my $panel = shift;
    my $self = $panel->game;
    
    return if $self->state ne &RUNNING;
    
    my $evt = shift;
    my $key = $evt->GetKeyCode();
    my $mino = $self->current_mino;
    
    $self->clear_mino_blocks;
    
    given ($key) {
        when ($_ == &Wx::WXK_LEFT) {
            $mino->move_left;
            $mino->move_right if !$self->move_is_valid;
        }
        
        when ($_ == &Wx::WXK_RIGHT) {
            $mino->move_right;
            $mino->move_left if !$self->move_is_valid;
        }
        
        when ($_ == &Wx::WXK_UP || $_ == ord 'X') {
            $mino->rotate_c;
            $mino->rotate_cc if !$self->move_is_valid;
        }
        
        when ($_ == ord 'Z') {
            $mino->rotate_cc;
            $mino->rotate_c if !$self->move_is_valid;
        }
        
        when ($_ == &Wx::WXK_DOWN) {
            $mino->fall;
            $mino->move_up if !$self->move_is_valid;
        }
        
        when ($_ == &Wx::WXK_SPACE) {
            $mino->fall while $self->move_is_valid;
            $mino->move_up;
            
            $self->_ticker->Stop();
            $self->tick();
            return if $self->state ne &RUNNING;
            $self->_ticker->Start(1000);
        }
    }
    
    $self->fill_mino_blocks;
    $self->board_panel->Refresh();
}

sub clear_stacked_rows () {
    my $self = shift;
    my @cells = @{$self->_get_cells};
    my $cleared_rows = 0;
    
    for (0..19) {
        my @row = @{$cells[$_]};
        my $row_is_stacked = 1;
        
        #Check if the row is full
        foreach my $cell (@row) {
            if (!$cell->is_stacked) {
                $row_is_stacked = 0;
                last;
            }
        }
        
        #Clear row if it's full
        if ($row_is_stacked) {
            $cleared_rows++;
            foreach my $cell (@row) {
                $cell->stack(0);
                $cell->fill(0);
            }
            
            #Move the above rows down one.
            for my $row_to_move (reverse 0..($_-1)) {
                
                my @row_to_move_from = @{$cells[$row_to_move]};
                my @row_to_move_to = @{$cells[$row_to_move+1]};
                
                #Move all the cells to the bottom_row
                #and clear the current one for the next loop;
                for my $cell (0..9) {
                    $row_to_move_to[$cell]->stack($row_to_move_from[$cell]->is_stacked);
                    $row_to_move_from[$cell]->stack(0);
                    $row_to_move_from[$cell]->fill(0);
                }
            }
        }
    }
    $self->_increment_score($cleared_rows);
}

sub _increment_score ($) {
    my ($self, $rows) = @_;
    my $score = $self->score;
    
    given ($rows) {
        when (1) {$score += 10}
        when (2) {$score += 25}
        when (3) {$score += 45}
        when (4) {$score += 70}
    }
    
    $self->_set_score($score);
    $self->score_panel->set_score($score);
}

sub stack_current_mino () {
    my $self = shift;
    my @cells = @{$self->_get_cells};
    my @coordinates = $self->current_mino->get_coords;
    
    foreach my $tuple (@coordinates) {
        $cells[$$tuple[1]][$$tuple[0]]->fill(1, $self->current_mino);
        $cells[$$tuple[1]][$$tuple[0]]->stack(1);
    }
}

sub move_is_valid () {
    my $self = shift;
    my @cells = @{$self->_get_cells};
    my @coordinates = $self->current_mino->get_coords;
    
    #Check move validity.
    foreach my $tuple (@coordinates) {
        return 0 if
        $$tuple[0] < 0 || $$tuple [0] > 9 ||            #x is not in range
        $$tuple[1] < 0 || $$tuple [1] > 19 ||           #y is not in range
        $cells[$$tuple[1]][$$tuple[0]]->is_stacked;     #mino collides with stacked block
    }
    
    return 1;
}

sub _build_state () {
    return &OVER;
}

sub _build_score () {
    return 0;
}

sub _build_ticker () {
    my $self = shift;
    my $ticker = Wx::Timer->new($self);
    #my $ticker = Wx::Timer->new();
}

sub _build_cells () {
    my @cells;
    
    foreach my $i (0..19) {
        my @row;
        foreach my $j (0..9) {
            push (@row, Block->new());
        }
        push (@cells, \@row);
    }
    return \@cells;
}

sub generate_mino () {
    my @minos = (
        sub{L_Mino->new(x => 5, y => 1)},
        sub{J_Mino->new(x => 5, y => 1)},
        sub{S_Mino->new(x => 5, y => 1)},
        sub{Z_Mino->new(x => 5, y => 1)},
        sub{I_Mino->new(x => 5, y => 1)},
        sub{O_Mino->new(x => 4, y => 0)},
        sub{T_Mino->new(x => 5, y => 1)}
    );
    
    $minos[rand scalar @minos]->();
}

sub clear_mino_blocks () {
    my $self = shift;
    
    my @coordinates = $self->current_mino->get_coords;
    my @cells = @{$self->_get_cells()};
    
    #Clear the cells.
    foreach my $tuple (@coordinates) {
        my $block = $cells[$$tuple[1]][$$tuple[0]];
        $block->fill(0);
    }
}

#
sub fill_mino_blocks () {
    my $self = shift;
    
    my @coordinates = $self->current_mino->get_coords;
    my @cells = @{$self->_get_cells()};
    
    #Fill the cells.
    foreach my $tuple (@coordinates) {
        my $block = $cells[$$tuple[1]][$$tuple[0]];
        $block->fill(1, $self->current_mino);
    }
}

sub clear_cells () {
    my $self = shift;
    my @cells = @{$self->_get_cells};
    
    foreach my $row (@cells) {
        my @row = @{$row};
        foreach my $cell (@row) {
            $cell->fill(0);
            $cell->stack(0);
        }
    }
}

sub start {
    my $self = shift;
    my $ticker = $self->_ticker;
    
    $self->clear_cells();
    
    $self->_set_score(0);
    $self->score_panel->set_score($self->score);
    
    my $mino = $self->generate_mino;
    $self->set_current_mino($mino);
    
    $self->set_state(&RUNNING);
    $self->board_panel->Refresh();
    $self->score_panel->Refresh();
    $ticker->Start(1000);
}

sub pause {
    my $self = shift;
    my $state = $self->state;
    
    if ($state eq &RUNNING) {
        $self->_ticker->Stop();
        $self->set_state(&PAUSED);
    } elsif ($state eq &PAUSED) {
        $self->_ticker->Start(1000);
        $self->set_state(&RUNNING);
    }
}

sub game_over {
    my $self = shift;
    my $ticker = $self->_ticker;
    
    $ticker->Stop();
    $self->set_state(&OVER);
    $self->_app->enable_menu_items(1,0,0);
    $self->board_panel->Refresh();
}

1;