

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