#!/usr/bin/env raku
use v6.d;

use JavaScript::Google::Charts;

my @data = (
    { name => 'Alice', region => 'East', sales => 12 },
    { name => 'Bob',   region => 'West', sales => 8  },
    { name => 'Cara',  region => 'East', sales => 15 },
);

my %spec = (
    data => @data,
    column-names => <name region sales>,
    controls => [
        %(id => 'region', type => 'CategoryFilter',
          options => %(filterColumnLabel => 'region')),
    ],
    charts => [
        %(id => 'sales', type => 'Column',
          view => %(columns => [0, 2]),
          options => %(title => 'Sales')),
    ],
    bindings => [
        %(controls => <region>, charts => <sales>),
    ],
    format => 'html',
    div-id => 'sales-dashboard',
);

spurt 'sales-dashboard.html', js-google-charts-dashboard(%spec);