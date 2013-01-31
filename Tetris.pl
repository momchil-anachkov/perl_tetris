#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

use Tetris;

my $app = Tetris->new();
$app->MainLoop();