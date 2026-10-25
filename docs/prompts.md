

## Controls and Dashboards

Links: ["Controls and Dashboards"](https://developers.google.com/chart/interactive/docs/gallery/controls).

```text
This Raku package produces HTML/JavaScript code for Google Charts via Raku code. 
I want to add controls and dashboards to the charts. 
I am not sure should these additions be made per char type (Scatter chart, Bar chart, etc.) or 
there is a possible universal Raku sub that can take, say, a JSON spec with the data, type of chart and the controls. 

Please review the Raku and outline a possible implementation plan. Do not implement anything yet.
```

```text
Ok. This is a good plan. Proceed implementing it. 
Program the dashboard specific Raku code in "./lib/JavaScript/Google/Charts/Dashboard.rakumod",
the Google snippets can be in "CodeSnippets.rakumod". 
The top level sub `js-google-charts-dashboard` should be in "./lib/JavaScript/Google/Charts.rakumod".
```

```text
Good. I have a Raku data of the form `[{x => 1.3, y => 3.3, index => 0, level => 1 }, ...]` 
make a Raku script in "./examples" that creates a dashboard with control for the index 
that scatter-plots all points with index up to slider's value.
```

----

## Proper respect for column names

````text
It looks like the named argument column-names is not respected in the calls of `js-google-charts`.
So, I am using `.subst` like in the code below. Any suggestions to fix this?

```raku
#% html
my @wide-data = @fin-data.kv.map(-> $i, @point {
    %(
        x => DateTime.new(Instant.from-posix(@point.head - $date-offset)),
        data => @point.tail,
        fit => @q-funcs[0](@point.head),
        anomaly => $i ∈ @pos ?? @point.tail !! Nil
    )
}).Array;

say deduce-type(@wide-data);

js-google-charts('Scatter', 
    @wide-data.map(*<x data fit anomaly>),
    title => 'Financial data, fit, and anomalies',
    :$titleTextStyle,
    series => { 
        0 => {color => 'Gray', pointSize => 2}, 
        1 => {color => 'SteelBlue', type => 'line', lineWidth => 3, pointSize => 0},
        2 => {color => 'Red', pointSize => 3},
    },
    legend => {
        position => 'right',
        textStyle => {
            color => '#dad5d5',
            fontSize => 12
        }
    },
    hAxis => {
        title => 'Date',
        format => 'yyyy-MM-dd'
    },
    :$backgroundColor, 
    :$chartArea, 
    :$format,
    :700width,
    :450height,
    div-id => 'fin-data-outliers'
)
.subst("data.addColumn('number', '1')", "data.addColumn('number', 'data')")
.subst("data.addColumn('number', '2')", "data.addColumn('number', 'fit')")
.subst("data.addColumn('number', '3')", "data.addColumn('number', 'anomaly')")
```
````