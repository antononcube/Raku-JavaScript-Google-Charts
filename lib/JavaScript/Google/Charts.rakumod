unit module JavaScript::Google::Charts;

use JavaScript::Google::Charts::CodeSnippets;
use JavaScript::Google::Charts::DataTable;
use Data::TypeSystem;
use Hash::Merge;
use JSON::Fast;

#============================================================
my $jsGoogleChartsConfigCode = q:to/END/;
google.charts.load('current', {'packages':['corechart']});
google.charts.load('current', {'packages':['gauge']});
google.charts.load('current', {packages:['wordtree']});
google.charts.load('current', {'packages':['geochart']});
google.charts.setOnLoadCallback(function() {
    console.log('Google Charts library loaded');
});
END

#| Configuration JavaScript code to be executed in %%javascript magic cell in a Jupyter notebook
sub js-google-charts-config() is export {
    return $jsGoogleChartsConfigCode;
}

#============================================================
our proto sub generate-code($data, :$column-names = Whatever, :$format = 'jupyter', *%args) {*}

our multi sub generate-code($data, :$column-names = Whatever, :$format = 'jupyter', *%args) {

    my $data-code = JavaScript::Google::Charts::DataTable::generate-code($data, :$column-names, version => 'row-by-row', n-tabs => 2);

    my %default = %(width => 600, height => 400);
    my %options = %args<options> // %();
    %options = reduce(&merge-hash, %default, %options, %args);
    my $options-code = %options ?? to-json(%options) !! '{}' ;

    my $code = JavaScript::Google::Charts::CodeSnippets::MainTemplate(:$format);

    return $code
            .subst('$DATA', $data-code)
            .subst('$OPTIONS', $options-code);
}

#============================================================
#| Umbrella function
proto sub js-google-charts(|) is export {*}

multi sub js-google-charts(Str:D $type, $data, *%args) {
    return js-google-charts($type, :$data, |%args)
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <bar barchart bar-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'BarChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <pie piechart pie-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'PieChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <bubble bubblechart bubble-chart>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
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
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'Histogram');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <scatter scatter-plot scatterplot list-plot listplot>,
                           :$data!,
                           :$column-names = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'ScatterChart');
}

multi sub js-google-charts(Str:D $type where *.lc ∈ <wordtree word-tree>,
                           :$data! is copy,
                           :$column-names is copy = Whatever,
                           :$format = 'jupyter',
                           *%args) {
    if $data ~~ Iterable:D && $data.all ~~ Str:D {
        $data = $data.map({ %(Phrases => $_) }).Array;
        $column-names = Whatever;
    }
    my $res = generate-code($data, :$column-names, :$format, |%args);
    return $res.subst('$CHART_NAME', 'WordTree');
}

multi sub js-google-charts(Str:D $type, :$data = Empty, *%args) {
    die "Unknown or unimplemented chart type ⎡$type⎦.";
}