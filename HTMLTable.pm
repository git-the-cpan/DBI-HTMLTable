package DBI::HTMLTable;
$VERSION='0.10';
use vars  qw ($VERSION);

sub HTMLTable {
  my ($data, $width) = @_;
  my ($i, $j, @cols, @theads, @trows, $thead,$topdatarow);
  my @rows = split /\n/, $data;
  if ($formatoption eq '-t') {
      @cols = split /\w*\|\w*/, $rows[1];
      shift @cols;
      $thead = $rows[1];
  } else {
      @cols = split /\s/, $rows[0];
      $thead = $rows[0];
  }
  my $cols = $#cols;
  if ($formatoption eq '-t' )  {
      @theads = split /\w*\|\w*/, $thead;
      shift @theads;
  } else {
      @theads = split /\s/, $thead;
  }
  print "<table width=\"$width\" cols=\"$cols\" border=\"2\" rules=\"all\">\n";
  print "<colgroup>\n";
  print "<tr>\n";
  if ($formatoption eq '-t' ) { 
      $topdatarow = 3;
  } else {
      $topdatarow = 1;
  }
  for ( $i = $topdatarow; $i <= $#rows; $i++ ) {
      next if $rows[$i] =~ /^\+\-\-/;
      my $trow = $rows[$i];
      if ($formatoption eq '-t' )  {
	  @trows = split /\w*\|\w*/, $trow;
	  shift @trows;
      } else {
	  @theads = split /\s/, $thead;
	  @trows = split /\s/, $trow;
      }
      for ( $j = 0; $j < $#cols; $j++ ) {
	  $trows[$j] = ' ' if not $trows[$j];
	  print "<td>".$trows[$j];
      }
      print "<tr>";
  }
  print "</colgroup>\n";
  print "</table>\n";
}

sub HTMLTableByRef {
  my ($dataref, $width) = @_;
  my ($i, $j, $nrows, $ncols, @rows);

  foreach (@$dataref) { push @rows, $_ }

  $nrows = $#rows;
  $ncols = scalar @{$rows[0]};

  no warnings;
  print qq/<table width\="$width" cols\="$ncols" border\="1">\n/;
  use warnings;
  print qq/<colgroup>\n/;

  for ( $i = 0; $i < $nrows; $i++ ) {
      print qq/<tr>\n/;
      for ( $j = 0; $j < $ncols; $j++ ) {
	  if ( not ${$rows[$i]}[$j]  or (${$rows[$i]}[$j] eq '') ) {
            ${$rows[$i]}[$j] = '--';
          }
	  print "<td>".${rows[$i]}[$j]."\n";
      }
  }

  print "</colgroup>\n";
  print "</table>\n";
}

1;
__END__;

=head1 NAME 

   HTMLTable - Make a HTML table from DBI query output.

=head1 SYNOPSIS

    use DBI::HTMLTable;

    &DBI::HTMLTable::HTMLTable ($data, $width);

    &DBI::HTMLTable::HTMLTableByRef ($dataref, $width);

=head1 DESCRIPTION

The DBI::HTMLTable functions take the results of a DBI 
query and format it as an HTML table.  The second parameter 
provides the width="" parameter to the <TABLE> tag in the 
output.  If it is omitted, then the table width is the browser's
default page width.

The function HTMLTable() uses the query output formatted as 
a multi-line string.  HTMLTableByRef uses a reference to 
an array of array references, as returned by the DBI 
fetchall_arrayref() function and similar functions.  

  $data = $dbh -> selectall_arrayref( "select \* from $db" );
  &DBI::HTMLTable::HTMLTableByRef ($data);

An example CGI script is provided in eg/tablequery.cgi in 
the distribution package.

=head1 VERSION

  First release, version 0.10 (alpha).

=head1 AUTHOR

  Robert Kiesling, rkiesling@mainmatter.com

=cut
  
