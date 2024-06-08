unit module JavaScript::Google::Charts::Bar;

use JavaScript::Google::Charts::CodeSnippets;
use JavaScript::Google::Charts::DataTable;
use Hash::Merge;
use JSON::Fast;

our proto sub generate-code($data, :$format = 'jupyter', *%args) {*}

our multi sub generate-code($data, :$format = 'jupyter', *%args) {

    my $data-code = JavaScript::Google::Charts::DataTable::generate-code($data, version => 'row-by-row', n-tabs => 2);

    my %default = %(width => 600, height => 400);
    my %options = %args<options> // %();
    %options = reduce(&merge-hash, %default, %options, %args);
    my $options-code = %options ?? to-json(%options) !! '{}' ;

    my $code = JavaScript::Google::Charts::CodeSnippets::MainTemplate(:$format);

    return $code
            .subst('$DATA', $data-code)
            .subst('$OPTIONS', $options-code)
            .subst('$CHART_NAME', 'BarChart');
}


