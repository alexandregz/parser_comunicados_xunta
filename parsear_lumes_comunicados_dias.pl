# abre un ficheiro coas urls a parsear de comunicados de lumes de 2025 da Xunta, unha por linha
# crea un .csv co seguinte formato:
#   lume1,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
#   lume2,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
#   ...
#   lumen,concello,hectareas_dia1,hectareas_dia2,hectareas_dia_n
#

use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;
use Data::Dumper;

use lib 'lib';
use parseador;

die "Uso: perl $0 FICHEIRO \n" unless($ARGV[0]);
my $ficheiro = $ARGV[0];

# hash final cos datos
my %data;

# abrimos ficheiro con urls
my $urls = do {
    local $/ = undef;
    open my $fh, "<", $ficheiro
        or die "non puiden abrir $ficheiro: $!";
    <$fh>;
};

# initialize the HTTP client
my $http = HTTP::Tiny->new();

# recorremos as urls do ficheiros
foreach my $url ( split(/\n/, $urls) ) {
    next if($url =~ /;/);   # permitimos comentarios estilo .ini, comezando por ;

    print "url: $url\n";

    # url
    my $response = $http->get($url);
    my $html_content = $response->{content};

    my $fecha = parseador::parseaFecha($html_content);
    # parsea os datos engadindo a infor nun hash "FECHA1=>datos_lumes1,FECHA2=>datos_lumes1"
    $data{$fecha} = parseador::parseadorXeral($html_content);

    print "----------\n";
}


print Dumper \%data;

die;

# cabeceira
print "lume;concello;estado;hectareas\n";

#loop hash con datos, ordeado por key (que é o lume)
foreach my $lume (sort {lc $a cmp lc $b} keys %data) {
    # NOTA: ás veces pode dar un warning tal que "Use of uninitialized value in sprintf at parsear_lumes_comunicados.pl line 125.",
    #  porque nos extinguidos non saen hectareas queimadas porque ás veces empreganse comas
    #  (p.e. As Neves-San pedro de batallans: 89,88 8 de agosto)
    print sprintf("%s;%s;%s;%s\n", $lume, $data{$lume}{concello}, $data{$lume}{estado}, $data{$lume}{hectareas});
}




# formatos: concello-parroquia; concello1-parroquia1 e concello2-parroquia2; concello1 (parroquia1 e parroquia2) e concello2-parroquia3; e algún máis
#   por comodidade so vou devolver o primeiro concelho!
sub _parsearConcelloMaisParroquia{
    my $lume = $_[0];
    
    # engadido: non fago return por casos como "Carballeda de Valdeorras-Casaio (anteriormente A Veiga-A Ponte)" e cambio o elsif por un if
    
    # Chandrexa de Queixa (Requeixo e Parafita) e Vilariño de Conso-Mormentelos, p.e.
    if($lume =~ /(.*?) \(/) {
        # return $1;
        $lume = $1;
    }
    # concello1-parroquia1
    # elsif($lume =~ /(.*?)\-(.*)?/) {
    if($lume =~ /(.*?)\-(.*)?/) {
        # return $1;  # concello1 directamente
        $lume = $1;
    }

    return $lume;
}

1;