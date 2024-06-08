#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use JavaScript::Google::Charts::DataTable;
use Data::Generators;

my @res = random-tabular-dataset(4, 2, generators => [{random-real(10, $_)}, &random-word]);

say @res;

say JavaScript::Google::Charts::DataTable::generate-code(@res);

say js-google-charts('Bar', @res);