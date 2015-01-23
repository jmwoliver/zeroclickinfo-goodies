package DDG::Goodie::Week;
# ABSTRACT: Find the current week number or when a week began

use DDG::Goodie;

# My imports
use strict;
use warnings;
use Lingua::EN::Numbers::Ordinate qw/ordinate ordsuf/;
use DateTime;
use Date::Calc qw(:all);

# File metadata
primary_example_queries "what is the current week";
secondary_example_queries "what was the 5th week of this year",
                          "what was the 5th week of 1944";
description "find the current week number or when a week began";
name "Week";
code_url "https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Week.pm";
category "dates";
topics "everyday", "special_interest";
attribution twitter => ["garrettsquire", 'Garrett Squire'],
            github => ["gsquire", 'Garrett Squire'];

triggers any => 'week';

zci is_cached => 1;
zci answer_type => "week";

my @months = qw/
    January
    February
    March
    April
    May
    June
    July
    August
    September
    October
    November
    December
/;

handle query_lc => sub {
    return unless /^\s*
        what(?:'?s|\sis|\swas)?\s
        (?:the\s)?
        (?:(current|(?<week>\d{1,2})(?:nd|th|rd|st)?)\s)?
        week
        (
            \sof\s
            (?:(?:the(?:\scurrent)?|this)\s)?
            (?<year>year|\d{4})
            |
            \sis\sthis
        )?\??
    \s*$/x;

    my $week = $+{week};
    my $year = $+{year} || 'current';
    $year = 'current' if $year eq 'year';

    ($week, $year) = qw/current current/ if (not defined $week);

    # ensure week number is legitimate
    return if $week =~ s/(nd|th|rd|st)$// and $week > 52;

    my $dt = DateTime->now(time_zone => $loc->time_zone);

    my $response;

    # Asking about current week of the current year
    if ($week eq 'current' and $year eq 'current') {
        my ($dt_week_num, $dt_year) = (ordinate($dt->week_number), $dt->year);
        $response = "We are currently in the $dt_week_num week of $dt_year.";
    }

    # Asking about nth week of the current year
    elsif ($year eq 'current') {
        $year = $dt->year();
    }

    # Asking about nth week of some year
    unless ($response){
        my (undef, $month, $day) = Monday_of_Week($week, $year);
        my ($week_num, $day_num, $out_month,  $start_term) = (ordinate($week), ordinate($day), $months[--$month], 'begins');

        $start_term = "began" if ($year < $dt->year || $week < $dt->week|| $day < $dt->day);

        $response = "The $week_num week of $year $start_term on $out_month $day_num.";
    }

    return $response,
      structured_answer => {
        input     => [],
        operation => "Assuming the week starts on Monday",
        result    => $response
      };
};

1;
