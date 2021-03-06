#!/usr/local/bin/perl -w

use CGI;
use DBI;
use DBI::HTMLTable;

#
# Edit the statement below for your SQL server's host name.
#
my $hostname = 'desktop';

# Some variable declarations
my ($table, $row, $rowsaffected, $i, $sth);

# HTML tags
my $hrule = "<p><hr><p>\n";

# Create a new query object
my $q = new CGI;

# Retrieve the parameters from the query form
my $user = $q -> param('username');     # User login and passwd
my $password = $q -> param('password');
my $db = $q -> param('dbname');         # Database name
my $query = $q -> param('query');       # SQL Query

# Connect to the database specified by the user.
my $dbh = DBI -> connect ("DBI:mysql:database=$db;host=$hostname;", 
	$user, $password );

# Print the HTML header;
print $q -> header;
print $q -> start_html( "Database: $db" );
print "<body bgcolor=\"#FFFFFF\" TEXT=\"#000000\">\n";

# Prepare and execute the user's query.
if ($query !~ /^\s+$/sm) { 

    $sth = $dbh -> prepare ($query);
    $rowsaffected = $sth -> execute;

    # Retrieve and format the output.
    my $headings = $sth -> {NAME};
    push @{$table}, [@$headings];
    for ($i = 1; ; $i++) {
       @row = $sth -> fetchrow_array;
       last if @row == 0;
       push @{$table}, [@row];
    }

    print "<h1>$query</h1>\n";
    &DBI::HTMLTable::HTMLTableByRef ($table, 500);
    print "Rows: $rowsaffected\n";

} else { # Show the contents of all tables

    $sth = $dbh -> prepare( 'show tables' );
    $sth -> execute;

    $colnames = $sth -> {'NAME'};
    $tablenames = $sth -> fetchall_arrayref();
    unshift @{$tablenames}, $colnames;
    print "<h4>Tables in <tt>$db</tt></h4>\n";

    &DBI::HTMLTable::HTMLTableByRef ($tablenames,100);

    print $hrule;

    foreach $t (@{$tablenames}) {
	next if ${$t}[0] =~ /Tables_in/;
        print "<h4>Table <tt>${$t}[0]</tt></h4>\n";
        $sth = $dbh -> prepare( "SELECT \* from ${$t}[0]" );
        $sth -> execute;
        $colnames = $sth -> {'NAME'};
        $tablenames = $sth -> fetchall_arrayref();
        $data = $dbh -> selectall_arrayref( "select \* from ${$t}[0]" );
        unshift @{$data}, $colnames;
    
        &DBI::HTMLTable::HTMLTableByRef ($data);
        print "<p><i>".
	  $sth -> rows." rows of ".
	  $sth -> {NUM_OF_FIELDS}.
	  " fields returned.</i><br>";
        print $hrule;
   }
}


# Disconnect from the database.
$dbh -> disconnect;

# Print the HTML trailer
print $q -> end_html;

