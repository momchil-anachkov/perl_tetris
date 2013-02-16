#!/usr/bin/perl -w
use strict;

package Score_Panel;


use Moose;
use MooseX::NonMoose;
extends qw(Wx::Panel);
use Data::Dumper;
use Wx;

=comment
Reference to the current game.
=cut
has game => (
    is => 'rw',
    isa => 'Game',
    reader => 'game',
	writer => 'set_game',
);

=comment
Score value for the label.
=cut
has score => (
	is => 'ro',
	isa => 'Int',
	writer => '_set_score',
	builder => '_build_score',
);

=comment
Label for the score.
=cut
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

=comment
Initializes the label after creation.
Note: The class members cannot be set if the panel is not created
with a concrete constructor or the 'create' method.
=cut
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

=comment
Sets the score value and updates the score label.
=cut
sub set_score ($) {
	my ($self, $score) = @_;
	
	$self->_set_score($score);
	$self->_label->SetLabel("Score: $score");
}

1;