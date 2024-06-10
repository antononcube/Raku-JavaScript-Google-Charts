unit module JavaScript::Google::Charts::CodeSnippets;


#============================================================
# Main HTML template
#============================================================
my $jsGoogleChartsMainTemplate-HTML = q:to/END/;
<html>
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">

      // Load the Visualization API and the corechart package.
      google.charts.load('current', {'packages':['corechart']});
      google.charts.load('current', {'packages':['gauge']});
      google.charts.load('current', {'packages':['wordtree']});
      google.charts.load('current', {'packages':['geochart']});
      google.charts.load('current', {'packages':['table']});
      google.charts.load('current', {'packages':['line']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.charts.setOnLoadCallback(drawChart);

      // Callback that creates and populates a data table,
      // instantiates the chart, passes in the data, and draws it.
      function drawChart() {

        // Create the data table.
        var data = $DATA;

        // Set chart options
        var options = $OPTIONS;

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.$CHART_NAME(document.getElementById('$DIV_ID'));
        chart.draw(data, options);
      }
    </script>
  </head>

  <body>
    <!--Div that will hold the pie chart-->
    <div id="$DIV_ID"></div>
  </body>
</html>
END

#============================================================
# Button HTML template
#============================================================

my $jsGoogleChartsImageURITemplate = q:to/END/;
        // Wait for the chart to finish drawing before calling the getImageURI() method.
        google.visualization.events.addListener(chart, 'ready', function () {
          $DIV_ID.innerHTML = '<img src="' + chart.getImageURI() + '">';
          console.log($DIV_ID.innerHTML);
        });

        chart.draw(data, options);

        document.getElementById('png_$DIV_ID').outerHTML = '<a href="' + chart.getImageURI() + '">PNG image</a>';
END

#============================================================
# Main Jupyter template
#============================================================

my $jsGoogleChartsMainTemplate = q:to/END/;
(function(element) {
    google.charts.setOnLoadCallback(function() {
        var data = $DATA;

        var options = $OPTIONS;

        var chart = new google.visualization.$CHART_NAME(element.get(0));

        chart.draw(data, options);
    });
})(element);
END

#============================================================
# Main templates access
#============================================================
our sub MainTemplate(Str:D :$format = 'jupyter', Bool:D :$png-button = False, Str:D :$div-id = 'chart_div') {
    return do given $format.lc {
        when 'jupyter' { $jsGoogleChartsMainTemplate }
        when 'html' {
            my $res = $jsGoogleChartsMainTemplate-HTML;
            if $png-button {
                $res = $res
                        .subst('chart.draw(data, options);', "\n$jsGoogleChartsImageURITemplate\n")
                        .subst('<div id="$DIV_ID"></div>', '<div id="$DIV_ID"></div>' ~ "\n\t" ~ '<div id="png_$DIV_ID"></div>');
            }
            $res.subst('$DIV_ID', $div-id, :g);
        }
        default {
            die "The format of a Google Charts template is expected to be one if <jupyter html>.";
        }
    }
}