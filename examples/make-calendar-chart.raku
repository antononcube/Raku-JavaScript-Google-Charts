#!/usr/bin/env raku
use v6.d;

use JavaScript::Google::Charts;

# One record per day. Replace this generated sample with application data of
# the form { date => Date, value => Numeric }.
my $start = Date.new(2025, 1, 1);
my @activity = (^365).map(-> $offset {
    my $date = $start + $offset;
    %(
        date => $date,
        value => 5 + (($offset * 17) % 40),
    )
}).Array;

spurt 'calendar-chart.html', js-google-charts(
    'Calendar',
    @activity,
    column-names => <date value>,
    format => 'html',
    div-id => 'daily-activity',
    title => 'Daily activity in 2025',
    width => 1000,
    height => 300,
    calendar => %(
        cellSize => 14,
        monthOutlineColor => %(stroke => '#666', strokeOpacity => 0.8, strokeWidth => 1),
        yearLabel => %(fontSize => 18, color => '#333')
    ),
    colorAxis => %(colors => ['#e8f5e9', '#006d2c'])
);
