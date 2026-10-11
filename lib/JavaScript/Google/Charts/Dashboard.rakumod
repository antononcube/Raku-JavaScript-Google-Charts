unit module JavaScript::Google::Charts::Dashboard;

use JavaScript::Google::Charts::CodeSnippets;
use JavaScript::Google::Charts::DataTable;
use Hash::Merge;
use JSON::Fast;

# Google dashboards use ChartWrapper, whose chart names are the classic
# google.visualization names. In particular, the package's Material `Line`
# alias is represented as a classic LineChart here.
sub chart-wrapper-type(Str:D $type) {
    my $name = $type.lc;
    return do given $name {
        when $_ ∈ <bar barchart bar-chart> { 'BarChart' }
        when $_ ∈ <column columnchart vertical-bar-chart> { 'ColumnChart' }
        when $_ ∈ <pie piechart pie-chart> { 'PieChart' }
        when $_ ∈ <area areachart> { 'AreaChart' }
        when $_ ∈ <stepped-area steppedareachart stepped-area-chart> { 'SteppedAreaChart' }
        when $_ ∈ <bubble bubblechart bubble-chart> { 'BubbleChart' }
        when $_ ∈ <gauge gaugechart gauge-chart> { 'Gauge' }
        when $_ ∈ <geo geochart geo-chart> { 'GeoChart' }
        when $_ ∈ <calendar calendarchart calendar-chart> { 'Calendar' }
        when $_ ∈ <hist histogram> { 'Histogram' }
        when $_ ∈ <sankey sankeydiagram sankey-diagram sankeychart sankey-chart> { 'Sankey' }
        when $_ ∈ <scatter scatterchart scatter-plot scatterplot list-plot listplot> { 'ScatterChart' }
        when $_ ∈ <line linechart line-chart material-lines material-line-chart list-line-plot listineplot> { 'LineChart' }
        when $_ ∈ <combo combochart combo-chart> { 'ComboChart' }
        when $_ ∈ <table table-chart tablechart> { 'Table' }
        when $_ ∈ <timeline timeline-chart timelinechart> { 'Timeline' }
        when $_ ∈ <wordtree word-tree> { 'WordTree' }
        default { die "Unknown or unimplemented dashboard chart type ⎡$type⎦." }
    }
}

sub valid-id(Str:D $id) {
    so $id ~~ /^ <[A..Za..z_]> <[A..Za..z0..9_\-]>* $/
}

sub require-id($value, Str:D $kind) {
    my $id = $value.Str;
    die "A dashboard $kind id must match /<[A..Za..z_]><[A..Za..z0..9_-]>*/; got ⎡$id⎦."
        unless valid-id($id);
    $id
}

sub as-id-list($value, Str:D $field) {
    my @ids = $value ~~ Str:D ?? ($value,) !! $value.list;
    die "A dashboard binding's '$field' must name at least one item." unless @ids.elems;
    @ids>>.Str
}

# Hashes slip into their pairs in ordinary Raku list literals. Accept both
# itemized Hash records and that convenient flattened spelling, using the
# required fields of each record to reassemble the latter. A repeated field
# starts the next flattened record, so hash iteration order does not matter.
sub records($value, Str:D $kind) {
    my @records;
    my %partial;
    for $value.list -> $item {
        if $item ~~ Pair:D {
            if %partial{$item.key.Str}:exists {
                @records.push: %partial.item;
                %partial = %();
            }
            %partial{$item.key.Str} = $item.value;
        } elsif $item ~~ Associative:D {
            die "Dashboard $kind records cannot mix itemized and flattened hashes."
                if %partial.elems;
            @records.push: $item.Hash.item;
        } else {
            die "Dashboard $kind entries must be Associative.";
        }
    }
    @records.push: %partial.item if %partial.elems;
    @records
}

#| Generate JavaScript or a standalone HTML document for a Google Charts dashboard.
our sub generate-dashboard-code(Associative:D $spec) is export {
    my %spec = $spec.Hash;
    die "A dashboard specification requires a 'data' entry." unless %spec<data>:exists;
    die "A dashboard specification requires a non-empty 'charts' entry."
        unless (%spec<charts>:exists) && %spec<charts>.elems;

    my $format = (%spec<format> // 'jupyter').Str;
    my $dashboard-id = require-id(%spec<div-id> // %spec<id> // 'dashboard_div', 'container');
    my $column-names = %spec<column-names> // Whatever;
    my @controls = records(%spec<controls> // [], 'controls');
    my @charts = records(%spec<charts>, 'charts');
    my @bindings = records(%spec<bindings> // [], 'bindings');

    my %control-vars;
    my %chart-vars;
    my @control-code;
    my @chart-code;
    my @body = "<div id=\"$dashboard-id\">";

    for @controls.kv -> $index, $control {
        die "Dashboard control number {$index + 1} must be Associative." unless $control ~~ Associative:D;
        my %control = $control.Hash;
        die "Dashboard control number {$index + 1} requires an 'id'." unless %control<id>:exists;
        die "Dashboard control '{$%control<id>}' requires a 'type'." unless %control<type>:exists;
        my $id = require-id(%control<id>, 'control');
        die "Dashboard control id ⎡$id⎦ is duplicated." if %control-vars{$id}:exists;

        my $options = %control<options> // %();
        die "Dashboard control '$id' options must be Associative." unless $options ~~ Associative:D;
        die "Dashboard control '$id' options require filterColumnLabel or filterColumnIndex."
            unless ($options<filterColumnLabel>:exists) || ($options<filterColumnIndex>:exists);

        my $container-id = "{$dashboard-id}-control-{$id}";
        my %wrapper = (
            controlType => %control<type>.Str,
            containerId => $container-id,
            options => $options.Hash
        );
        %wrapper<state> = %control<state> if %control<state>:exists;
        my $var = "control_$index";
        %control-vars{$id} = $var;
        @control-code.push("var $var = new google.visualization.ControlWrapper(" ~ to-json(%wrapper) ~ ");");
        @body.push("  <div id=\"$container-id\"></div>");
    }

    for @charts.kv -> $index, $chart {
        die "Dashboard chart number {$index + 1} must be Associative." unless $chart ~~ Associative:D;
        my %chart = $chart.Hash;
        die "Dashboard chart number {$index + 1} requires an 'id'." unless %chart<id>:exists;
        die "Dashboard chart '{$%chart<id>}' requires a 'type'." unless %chart<type>:exists;
        my $id = require-id(%chart<id>, 'chart');
        die "Dashboard chart id ⎡$id⎦ is duplicated." if %chart-vars{$id}:exists;

        my %options = %(width => 600, height => 400);
        if %chart<options>:exists {
            die "Dashboard chart '$id' options must be Associative." unless %chart<options> ~~ Associative:D;
            %options = merge-hash(%options, %chart<options>.Hash);
        }
        my $container-id = "{$dashboard-id}-chart-{$id}";
        my %wrapper = (
            chartType => chart-wrapper-type(%chart<type>.Str),
            containerId => $container-id,
            options => %options
        );
        %wrapper<view> = %chart<view> if %chart<view>:exists;
        my $var = "chart_$index";
        %chart-vars{$id} = $var;
        @chart-code.push("var $var = new google.visualization.ChartWrapper(" ~ to-json(%wrapper) ~ ");");
        @body.push("  <div id=\"$container-id\"></div>");
    }
    @body.push('</div>');

    my @binding-code;
    for @bindings.kv -> $index, $binding {
        die "Dashboard binding number {$index + 1} must be Associative." unless $binding ~~ Associative:D;
        my %binding = $binding.Hash;
        die "Dashboard binding number {$index + 1} requires 'controls' and 'charts'."
            unless (%binding<controls>:exists) && (%binding<charts>:exists);
        my @control-ids = as-id-list(%binding<controls>, 'controls');
        my @chart-ids = as-id-list(%binding<charts>, 'charts');
        for @control-ids -> $id { die "Dashboard binding references unknown control ⎡$id⎦." unless %control-vars{$id}:exists; }
        for @chart-ids -> $id { die "Dashboard binding references unknown chart ⎡$id⎦." unless %chart-vars{$id}:exists; }
        @binding-code.push(
            'dashboard.bind([' ~ @control-ids.map({ %control-vars{$_} }).join(', ') ~ '], [' ~
            @chart-ids.map({ %chart-vars{$_} }).join(', ') ~ ']);'
        );
    }

    my $data-code = JavaScript::Google::Charts::DataTable::generate-code(
        %spec<data>, :$column-names, version => 'row-by-row', n-tabs => 0
    );
    my $dashboard-code = "var data = $data-code\n" ~
        "var dashboard = new google.visualization.Dashboard(document.getElementById('$dashboard-id'));\n" ~
        (@control-code, @chart-code, @binding-code, 'dashboard.draw(data);').join("\n");
    my $body = @body.join("\n");
    my $template = JavaScript::Google::Charts::CodeSnippets::DashboardTemplate(:$format);
    my $body-code = $format.lc eq 'jupyter' ?? to-json($body) !! $body;

    $template.subst('$BODY', $body-code).subst('$DASHBOARD_CODE', $dashboard-code);
}
