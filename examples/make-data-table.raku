#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @res = random-tabular-dataset(4, <x y>, generators => [{random-real(10, $_)}, {random-real(50, $_)}]);

say js-google-charts('Scatter',column-names => <x y>, @res);