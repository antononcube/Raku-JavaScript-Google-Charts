unit module JavaScript::Google::Charts::DataTable;

use Data::TypeSystem;
use Data::TypeSystem::Predicates;

sub type-ordinal($t) {
    return do given $t {
        when $_ ~~ Str:D {1}
        when $_ ~~ Numeric:D {2}
        when $_ ~~ DateTime:D {3}
        default { 10 }
    };
}

our proto sub generate-code($data, :$column-names = Whatever, :$version = 1, UInt :$n-tabs = 0) {*}

our multi sub generate-code($data, :$column-names = Whatever, :$version = 'row-by-row', UInt :$n-tabs = 0) {
    return do given $version.Str {
        when $_ ∈ <1 row-by-row> {
            generate-code-row-by-row($data, :$column-names, :$n-tabs)
        }
    }
}

sub generate-code-row-by-row($data, :$column-names is copy = Whatever, UInt :$n-tabs = 0) {

    if !is-reshapable($data, iterable-type => Iterable, record-type => Associative) {
        die "The first (data) argument is expected to be an Iterable of Associative's.";
    }

    # Declare data table
    # The full code line should be something like:
    #   "var data = new google.visualization.DataTable();"
    my @res = "new google.visualization.DataTable();";

    # Find column names and types
    my @colnames;
    if $column-names.isa(Whatever) {
        @colnames = $data.head.keys.sort({ type-ordinal($data.head{$_}) });
    } elsif $column-names ~~ Iterable:D && $column-names.elems ≥ 2 {
        @colnames = |$column-names>>.Str;
    } else {
        die "The argument \$column-names is expected to be an Iterable of length at least two or Whatever.";
    }

    # Declare columns
    for @colnames -> $c {

        my $col-type = do given $data.head{$c} {
            when DateTime:D { 'datetime' }
            when Numeric:D { 'number' }
            when Str:D { 'string' }
            default {
                die "Do not know how to process ⎡$_⎦.";
            }
        }

        @res.push("data.addColumn('{ $col-type }', '$c');");
    }

    # Add rows
    my @data-rows;
    for |$data -> %record {
        my %h = %record.clone;

       %h = %h.deepmap({
            given $_ {
                when Str:D { "'$_'"}
                when Numeric:D {$_}
                when DateTime:D {"new Date({$_.year}, {$_.month}, {$_.day})"}
                default {
                    die "Do not know how to process ⎡$_⎦.";
                }
            }
        });

        @data-rows.push("[{%h{|@colnames}.join(', ')}]")
    }

    @res.push('data.addRows([');
    @res.push(@data-rows.join(",\n"));
    @res.push('])');

    # result
    return do if $n-tabs {
        @res.join("\n").lines.map({ ("\t" x $n-tabs) ~ $_}).join("\n").trim;
    } else {
        @res.join("\n");
    }
}
