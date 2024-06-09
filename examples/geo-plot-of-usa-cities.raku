#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use JavaScript::Google::Charts;
use Data::Geographics;
use Data::TypeSystem;

my $titleTextStyle = { color => 'White' };
my $backgroundColor = '#1D1D1D';
my $legendTextStyle = { color => 'White' };

my @dsCityData = city-data().grep({ $_<Country> eq 'United States' && $_<Population> ≥ 1_000 });
my @column-names = <Latitude Longitude Label Value>;
@dsCityData = @dsCityData.map({ <Latitude Longitude Label Value> Z=> $_<Latitude Longitude City Population> })».Hash;

my @dsCityData2 = @dsCityData.map({
    my %h = $_.clone;
    %h<Value> = %(v => %h<Value>.log10, f => %h<Value>.Str);
    %h
});

deduce-type(@dsCityData2);

spurt 'usa-cities-geo-plot.html',
        js-google-charts('GeoChart',
                @dsCityData2,
                :@column-names,
                width => 1600,
                height => 800,
                title => 'Populations',
                region => 'US',
                colors => ['blue', 'red'],
                :$titleTextStyle,
                :$backgroundColor,
                :$legendTextStyle,
                format => 'html'
        );