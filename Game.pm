package Game;
use Moose;
use MooseX::NonMoose;

extends qw(Wx::EvtHandler);

use Wx;
use Wx::Event qw(EVT_TIMER);
use Moose::Util::TypeConstraints;

use Board;
use Board_Panel;

use L_Mino;

use Data::Dumper;

use constant {
        RUNNING   => 'running',
        PAUSED   => 'paused',
};

enum 'valid_state', [&RUNNING, &PAUSED];
has state => (
    is => 'rw',
    isa => 'valid_state',
    reader => 'state',
    writer => 'set_state',
    builder => '_build_state',
);

has _ticker => (
    is => 'bare',
    isa => 'Wx::Timer',
    reader => '_ticker',
    builder => '_build_ticker',
);

has panel => (
    is => 'ro',
    isa => 'Board_Panel',
    reader => 'get_panel',
    builder => '_build_panel'
);

has board => (
    is => 'ro',
    isa => 'Board',
    reader => 'board',
    builder => '_build_board',
);

sub get_cells () {
    my $self = shift;
    $self->board->get_cells();
}

sub BUILD () {
    my $self = shift;
    #print Dumper $self;
    
    EVT_TIMER( $self, -1, \&tick);
    #$self->_ticker->Start(1000);
}

sub tick () {
    my $self = shift;
    $self->board->move_mino_down;
    $self->board->fill_mino_blocks;
    $self->get_panel->Refresh();
    #print 'something';
    #print Dumper $self;
}

sub _build_state () {
    return &RUNNING;
}

sub _build_ticker () {
    my $self = shift;
    my $ticker = Wx::Timer->new($self);
}

sub _build_panel () {
    my $self = shift;
    my $panel = Board_Panel->new('game', $self);
}

sub _build_board () {
    my $board = Board->new();
    $board->set_current_mino(L_Mino->new('x', 7, 'y', 3));
    $board;
}

sub start () {
    my $self = shift;
    my $ticker = $self->_ticker;
    
    #print Dumper $ticker;
    
    $ticker->Start(1000);
}

1;