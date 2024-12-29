#!/usr/bin/env raku
use v6.d;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @data = {Label => 'Minutes', Value => 10}, {Label => 'Seconds', Value => 27};
spurt 'gauge.html', js-google-charts('Gauge', :@data, format => 'html');