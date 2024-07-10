unit module JavaScript::Google::Charts;

use JavaScript::Google::Charts::CodeSnippets;
use JavaScript::Google::Charts::DataTable;
use Data::TypeSystem;
use Hash::Merge;
use JSON::Fast;

#============================================================
my $jsGoogleChartsConfigCode = q:to/END/;
google.charts.setOnLoadCallback(function() {
    console.log('Google Charts library loaded');
});
END

#| Configuration JavaScript code to be executed in %%javascript magic cell in a Jupyter notebook
sub js-google-charts-config() is export {
    return JavaScript::Google::CodeSnippets::GetGoogleChartsPackages() ~ "\n" ~ $jsGoogleChartsConfigCode;
}

#============================================================
our proto sub generate-code($data,
                            :$column-names = Whatever,
                            :$format = 'jupyter',
                            Bool:D :$png-button = False,
                            Str:D :$div-id = 'chart_div',
                            *%args) is export {*}

our multi sub generate-code($data,
                            :$column-names = Whatever,
                            :$format = 'jupyter',
                            Bool:D :$png-button = False,
                            Str:D :$div-id = 'chart_div',
                            *%args) {

    my $data-code = JavaScript::Google::Charts::DataTable::generate-code($data, :$column-names, version => 'row-by-row', n-tabs => 2);

    my %default = %(width => 600, height => 400);
    my %options = %args<options> // %();
    %options = reduce(&merge-hash, %default, %options, %args);
    my $options-code = %options ?? to-json(%options) !! '{}' ;

    my $code = JavaScript::Google::Charts::CodeSnippets::MainTemplate(:$format, :$png-button, :$div-id);

    return $code
            .subst('$DATA', $data-code)
            .subst(/ ^^ (\h*) '$OPTIONS' /, { $options-code.lines.map(-> $l {"{$0.Str}$l"} ).join("\n") });
}

#============================================================
#| Umbrella function
proto sub js-google-charts(|) is export {*}

multi sub js-google-charts(Str:D $type, Seq:D $data, *%args) {
    return js-google-charts($type, data => $data.cache, |%args);
}

multi sub js-google-charts(Str:D $type, $data, *%args) {
    return js-google-charts($type, :$data, |%args);
}

# Does not seem to have an effect.
#multi sub js-google-charts(Str:D $type, Seq:D :$data!, *%args) {
#    return js-google-charts($type, data => $data.cache, |%args);
#}

multi sub js-google-charts(Str:D $type where *.lc ∈ <bar barchart bar-chart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           Bool :h(:$horizontal) = True,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Numeric:D {
        my $k = 1;
        $data = $data.map({ %(name => ($k++).Str, value => $_) }).Array;
        $column-names = <name value>;
    } elsif $data ~~ Map:D && $data.values.all ~~ Numeric:D {
        $data = $data.map({ %(name => $_.key, value => $_.value) }).Array;
        $column-names = <name value>;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);

    return $res.subst('$CHART_NAME', $horizontal ?? 'BarChart' !! 'ColumnChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <column columnchart vertical-bar-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    return js-google-charts('BarChart', :$data, :$column-names, :!horizontal, :$format, |%args);
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <pie piechart pie-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = js-google-charts('BarChart', :$data, :$column-names, :$format, |%args);
    return $res.subst('BarChart', 'PieChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <area areachart>,
                           :$data!,
                           :$column-names = Whatever,
                           Bool :s(:$stepped) = False,
                           :$format = 'jupyter',
                           *%args) {
    my %args2 = %args.grep({ $_.key ne 'horizontal' });
    my $res = js-google-charts('BarChart', :$data, :$column-names, :horizontal, :$format, |%args2);
    return $res.subst('BarChart', $stepped ?? 'SteppedAreaChart' !! 'AreaChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <stepped-area steppedareachart stepped-area-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           Bool :s(:$stepped) = False,
                           :$format = 'jupyter',
                           *%args) {
    return js-google-charts('AreaChart', :$data, :$column-names, :stepped, :$format, |%args);
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <bubble bubblechart bubble-chart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Numeric:D {
        my $k = 1;
        $data = $data.map({ %(name => ($k++).Str, x => $k, y => $_, group => $k, size => $_) }).Array;
        $column-names = <name x y group size>;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'BubbleChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <gauge gaugechart gauge-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {

    my $min = %args<min> // 0;
    my $max = %args<max> // 100;
    my $span = $max - $min;

    my %options =
            :width(400), :height(120),
            :$min, :$max,
            minorTicks => round(0.05 * $span),
            redFrom => round(0.9 * $span), redTo => ceiling($span),
            yellowFrom => round(0.75 * $span), yellowTo => round(0.9 * $span);

    my $res = generate-code($data, :$column-names, :$format, |%options, |%args);

    return $res.subst('$CHART_NAME', 'Gauge');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <geochart geo-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'GeoChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <hist histogram>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Numeric:D {
        $data = $data.map({ %(value => $_) }).Array;
        $column-names = Whatever;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'Histogram');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <sankey sankeydiagram sankey-diagram sankeychart sankey-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'Sankey');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <scatterchart scatter scatter-plot scatterplot list-plot listplot>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Numeric:D {
        my $k = 1;
        $data = $data.map({ %(x => $k++, y => $_) }).Array;
        $column-names = <x y>;
    } elsif is-reshapable(Iterable, Positional, $data) || is-reshapable(Iterable, Seq, $data) {
        my $k = $data.head.elems;
        $column-names = (^$k)».Str;
        $data = $data.map({ $column-names.Array Z=> $_.Array })».Hash.Array;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'ScatterChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <linechart line-chart list-line-plot listineplot>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {

    my $res = js-google-charts('ScatterChart', :$data, :$column-names, :$format, |%args);
    return $res.subst('ScatterChart', 'LineChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <line material-lines material-line-chart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {

    my $res = js-google-charts('LineChart', :$data, :$column-names, :$format, |%args);
    $res .= subst('google.visualization.LineChart', 'google.charts.Line');
    $res .= subst('chart.draw(data, options)', 'chart.draw(data, google.charts.Line.convertOptions(options))');
    return $res;
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <combo combochart combo-chart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = js-google-charts('ScatterChart', :$data, :$column-names, :$format, |%args);
    return $res.subst('ScatterChart', 'ComboChart'):g;
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <table table-chart tablechart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Numeric:D {
        $data = $data.map({ %(value => $_) }).Array;
        $column-names = Whatever;
    }
    my %default = :showRowNumber, width => '100%', height => '100%';
    my %args2 = merge-hash(%default, %args);
    my $res = generate-code($data, :$column-names, :$format, |%args2);
    return $res.subst('$CHART_NAME', 'Table');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <timeline timeline-chart timelinechart>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'Timeline');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <wordtree word-tree>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Str:D {
        $data = $data.map({ %(String => $_) }).Array;
        $column-names = Whatever;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'WordTree');
}

multi sub js-google-charts(Str:D $type, :$data = Empty, *%args) {
    die "Unknown or unimplemented chart type ⎡$type⎦.";
}