#!/usr/bin/env raku
use v6.d;

use JavaScript::Google::Charts;

my @data = (^100).map(-> $n {
    my $index = ($n div 10).Int;
    %(
        x => $index + (($n % 10) / 10),
        y => 5 + 3 * sin($n / 6) + (($n % 5) / 3),
        index => $index,
        level => 1 + ($n % 3),
    )
}).Array;

my $maximum-index = @data.map(*<index>).max;

my %spec = (
data => @data,
column-names => <x y index level>,
controls => [
    %(id => 'index-cutoff', type => 'NumberRangeFilter',
      options => %(
          filterColumnLabel => 'index',
          minValue => 0,
          maxValue => $maximum-index,
          ui => %(label => 'Show points with index up to')
      ),
      # Keep the lower bound at zero; move the upper thumb to set the cutoff.
      state => %(lowValue => 0, highValue => $maximum-index)),
],
charts => [
    %(id => 'points', type => 'Scatter',
      view => %(columns => [0, 1]),
      options => %(
          title => 'Points up to the selected index',
          hAxis => %(title => 'x'),
          vAxis => %(title => 'y')
      )),
],
bindings => [
    %(controls => <index-cutoff>, charts => <points>),
],
format => 'html',
div-id => 'index-dashboard',
);

spurt 'index-dashboard.html', js-google-charts-dashboard(%spec);
