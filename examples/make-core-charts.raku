#!/usr/bin/env raku
use v6.d;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @data1 = random-real(120, 12);

spurt 'scatter-plot-1.html', js-google-charts('Scatter', @data1, format => 'html');

spurt 'list-line-plot-1.html', js-google-charts('Line', @data1, format => 'html');

spurt 'material-line-plot-1.html', js-google-charts('Line', @data1, format => 'html');

spurt 'bar-chart-1.html', js-google-charts('Bar', @data1, format => 'html'):!h;

spurt 'pie-chart-1.html', js-google-charts('Pie', @data1, format => 'html');

spurt 'histogram-1.html', js-google-charts('Histogram', @data1, format => 'html');

spurt 'buble-chart-1.html', js-google-charts('BubbleChart', @data1, format => 'html', :png-button);

my @data2 = random-tabular-dataset(4, <x y>, generators => [{random-real(10, $_)}, {random-real(50, $_)}]);

spurt 'scatter-plot-2.html', js-google-charts('Scatter', column-names => <x y>, @data2, format => 'html');

my @data3 = random-real(120, 40).rotor(2);

spurt 'scatter-plot-3.html', js-google-charts('Scatter', @data3, format => 'html');
