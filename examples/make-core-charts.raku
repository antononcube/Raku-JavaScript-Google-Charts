#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @res1 = random-real(120, 12);

spurt 'scatter-plot-1.html', js-google-charts('Scatter', @res1, format => 'html');

spurt 'list-line-plot-1.html', js-google-charts('Line', @res1, format => 'html');

spurt 'material-line-plot-1.html', js-google-charts('Line', @res1, format => 'html');

spurt 'bar-chart-1.html', js-google-charts('Bar', @res1, format => 'html');

spurt 'pie-chart-1.html', js-google-charts('Pie', @res1, format => 'html');

spurt 'histogram-1.html', js-google-charts('Histogram', @res1, format => 'html');

spurt 'buble-chart-1.html', js-google-charts('BubbleChart', @res1, format => 'html', :png-button);

my @res2 = random-tabular-dataset(4, <x y>, generators => [{random-real(10, $_)}, {random-real(50, $_)}]);

spurt 'scater-plot-2.html', js-google-charts('Scatter', column-names => <x y>, @res2, format => 'html');