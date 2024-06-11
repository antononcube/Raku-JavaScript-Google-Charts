#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @res = random-tabular-dataset(6, <From To Weight>,
        generators => [
                {<France Portugal Brazil Spain Mexico Argentina Moroco Canada USA>.pick($_).cache},
                {<France Portugal Brazil Spain Mexico Argentina Moroco Canada USA>.pick($_).cache},
                {random-real((1, 10), $_)».round.cache}
        ]);


say @res;

spurt 'sankey-diagram.html',
        js-google-charts('SankeyDiagram',
                @res,
                :isStacked,
                bar => { groupWidth => '75%' },
                format => 'html');
