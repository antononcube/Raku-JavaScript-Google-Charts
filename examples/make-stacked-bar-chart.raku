#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @res = random-tabular-dataset(4, 4,
        generators => [{<2000 2010 2020 2030>.pick($_).cache},
                       {random-real((10,20), $_)».round.cache},
                       {random-real((2,6), $_)».round.cache},
                       {random-real((15, 30), $_)».round.cache}
        ]);

@res = @res.map({ $_<role:annotation> = ''; $_});

say @res;

spurt 'stacked-bar-chart-1.html',
        js-google-charts('BarChart',
                @res,
                :!horizontal,
                :isStacked,
                bar => { groupWidth => '75%' },
                format => 'html');

# Note that a pie- or an area chart can be
# simply obtained by applying this substitution:
#       subst('ColumnChart', 'AreaChart');
