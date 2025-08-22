use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;
use Data::Dumper;

use lib 'lib';
use parseador;

die "Uso: perl $0 URL \n" unless($ARGV[0]);
my $url = $ARGV[0];

# initialize the HTTP client
my $http = HTTP::Tiny->new();
# Retrieve the HTML code of the page to scrape
my $response = $http->get($url);
my $html_content = $response->{content};


# # DEBUG
# # my $file = "3agosto2025.txt";
# # my $file = "19agosto2025.txt";
# # my $file = "08agosto2025.txt";
# my $file = "06agosto2025.txt";
# my $html_content = do {
#     local $/ = undef;
#     open my $fh, "<", $file
#         or die "could not open $file: $!";
#     <$fh>;
# };

# desreferencio o hash, necesito que sexa unha referencia en parsear_lumes_comunicados_dia
my %data = %{parseador::parseadorXeral($html_content)};

# print Dumper(\%data);

# cabeceira
print "lume;concello;estado;hectareas\n";

#loop hash con datos, ordeado por key (que é o lume)
foreach my $lume (sort {lc $a cmp lc $b} keys %data) {
    # NOTA: ás veces pode dar un warning tal que "Use of uninitialized value in sprintf at parsear_lumes_comunicados.pl line 125.",
    #  porque nos extinguidos non saen hectareas queimadas porque ás veces empreganse comas
    #  (p.e. As Neves-San pedro de batallans: 89,88 8 de agosto)
    print sprintf("%s;%s;%s;%s\n", $lume, $data{$lume}{concello}, $data{$lume}{estado}, $data{$lume}{hectareas});
}

1;