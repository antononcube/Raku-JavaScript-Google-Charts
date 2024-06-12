#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @tbl = random-tabular-dataset(12,
        <position name start end>,
        generators => [
            { random-pet-name($_) },
            {["president", "vice president", "secretary of state"].roll($_).List },
            { random-date-time((DateTime.new(2018, 1, 1, 0, 0, 0), DateTime.new(2021, 1, 1, 0, 0, 0)), $_)».Date.List },
            { random-date-time((DateTime.new(2022, 1, 1, 0, 0, 0), DateTime.new(2024, 1, 1, 0, 0, 0)), $_)».Date.List }
        ]);

.say for @tbl;

spurt 'timeline.html', js-google-charts('Timeline', @tbl, format => 'html');