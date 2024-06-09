#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @phrases =
        'cats are better than dogs',
        'cats eat kibble',
        'cats are better than hamsters',
        'cats are awesome',
        'cats are people too',
        'cats eat mice',
        'cats meowing',
        'cats in the cradle',
        'cats eat mice',
        'cats in the cradle lyrics',
        'cats eat kibble',
        'cats for adoption',
        'cats are family',
        'cats eat mice',
        'cats are better than kittens',
        'cats are evil',
        'cats are weird',
        'cats eat mice';

spurt 'word-tree.html', js-google-charts('WordTree', @phrases, format => 'html');