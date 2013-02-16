#!/usr/bin/perl -w
use strict;

package Score_Panel;


use Moose;
use MooseX::NonMoose;
extends qw(Wx::Panel);
use Data::Dumper;
use Wx;

has game => (
    is => 'rw',
    isa => 'Game',
    reader => 'game',
	writer => 'set_game',
);

has score => (
	is => 'ro',
	isa => 'Int',
	writer => '_set_score',
	builder => '_build_score',
);

has label => (
	is => 'bare',
	isa => 'Wx::StaticText',
	reader => '_label',
	writer => '_set_label',
);
after 'Create'  => \&_init;

sub _build_score () {
	return 0;
}

sub _init () {
	my $self = shift;
	my $score = $self->score;
	
	my $test_panel = Wx::Panel->new();
	
	if (!defined($self->_label)) {
		my $label = Wx::StaticText->new(
			$self,
			-1,
			"Score: 0",
		);
		my $font = Wx::Font->new(15, &Wx::wxFONTFAMILY_DEFAULT, &Wx::wxFONTSTYLE_NORMAL, &Wx::wxFONTWEIGHT_NORMAL);
		$label->SetFont($font);
		$label->Center();
		$self->_set_label($label);
	}
}

#sub BUILD () {
#    my $self = shift;
#    
#    $self->SetBackgroundColour(Wx::Colour->new(255,255,255));
#    $self->Refresh();
#    $self->SetBackgroundStyle(&Wx::wxBG_STYLE_CUSTOM);
#}

sub set_score ($) {
	my ($self, $score) = @_;
	
	$self->_set_score($score);
	$self->_label->SetLabel("Score: $score");
}

1;