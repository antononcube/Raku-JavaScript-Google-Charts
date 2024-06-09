#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @tbl = random-tabular-dataset(12,
        <name position salary vaccinated>,
        generators => [
            &random-pet-name,
            &random-pretentious-job-title,
            { random-variate(NormalDistribution.new(40_000, 10_000), $_)».round(100)},
            { (True, False).roll($_).Array }
        ]);

spurt 'table.html', js-google-charts('Table', @tbl.sort(*<salary>).Array, format => 'html');