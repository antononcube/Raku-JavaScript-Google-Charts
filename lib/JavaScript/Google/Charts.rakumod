unit module JavaScript::Google::Charts;

use JavaScript::Google::Charts::CodeSnippets;
use JavaScript::Google::Charts::Bar;

#============================================================
my $jsGoogleChartsConfigCode = q:to/END/;
google.charts.load('current', {'packages':['corechart']});
google.charts.load('current', {'packages':['geochart']});
google.charts.setOnLoadCallback(function() {
    console.log('Google Charts library loaded');
});
END

#| Configuration JavaScript code to be executed in %%javascript magic cell in a Jupyter notebook
sub js-d3-config() is export {
    return $jsGoogleChartsConfigCode;
}

#============================================================
#| Umbrella function
proto sub js-google-charts(|) is export {*}

multi sub js-google-charts(Str:D $type, $data, *%args) {
    return js-google-charts($type, :$data, |%args)
}

multi sub js-google-charts(Str:D $type where *.lc eq 'bar', :$data, :$format = 'jupyter', *%args) {
    JavaScript::Google::Charts::Bar::generate-code($data, :$format, |%args);
}

multi sub js-google-charts(Str:D $type, :$data = Empty, *%args) {
    die "Unknown or unimplemented type ⎡$type⎦.";
}