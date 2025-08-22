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
use Time::Piece;

use lib 'lib';
use parseador;

# separador entre campos (Flourish emprega "," no csv, Excel ";")
my $SEPARADOR = ',';


die "Uso: perl $0 FICHEIRO [conservar_lumes=1]\n" unless($ARGV[0]);
my $ficheiro = $ARGV[0];
my $conservar_lumes = $ARGV[1] || undef;        # dá unha vision global de como foi todo o verán

#hash de datos en bruto e que se empregará tamén ao final con fechas
my %data;
# hash final de dato de lumes
my %dataLumes;


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
    $url = parseador::trim($url);

    next if($url =~ /;/);   # permitimos comentarios estilo .ini, comezando por ;
    next if($url eq '');   # permitimos linhas baleiras por claridade
    # print "url: $url\n";

    # url
    my $response = $http->get($url);
    my $html_content = $response->{content};

    my $fecha = parseador::parseaFecha($html_content);
    # parsea os datos engadindo a infor nun hash "FECHA1=>datos_lumes1,FECHA2=>datos_lumes1"
    $data{$fecha} = parseador::parseadorXeral($html_content);
    # print "----------\n";
}
# print Dumper \%data;


# loop de hash para cargar os datos por lumes en %dataLumes
# Aqui cómpre revisar os lumes, algúns cambiaron de nome (p.e. "Carballeda de Valdeorras-Casaio (anteriormente A Veiga-A Ponte)" !!) 
foreach my $dia (keys(%data)) {

    foreach my $lume (keys(%{$data{$dia}})) {
        $dataLumes{$lume} = $data{$dia}{$lume} unless($dataLumes{$lume});   # meto os datos "velhos"
        $dataLumes{$lume}{$dia} = $data{$dia}{$lume}{'hectareas'};          # meto as hectareas de cada dia, empregando dia de key
        delete($dataLumes{$lume}{hectareas});                               # e elimino a key hectareas, que non se usa
    }
}
# print Dumper \%dataLumes;


# cos dous hashes xa somos quen de facer output

# creamos un array coas keys ordeadas de data mais antiga a mais nova
my @sorted_keys_asc = sort {
    Time::Piece->strptime($a, '%d/%m/%Y') <=> Time::Piece->strptime($b, '%d/%m/%Y')
} keys %data;


# hash temporal para ultimo resultado, para conservalo no caso de que queiramos que se vexan todos os lumes, extinguidos, controlados, etc.
my %ultimoResultadoHectareas;

# cabeceira
print "lume $SEPARADOR concello $SEPARADOR estado $SEPARADOR".join($SEPARADOR, @sorted_keys_asc)."\n";

#loop hash con datos, ordeado por key (que é o lume)
foreach my $lume (sort {lc $a cmp lc $b} keys %dataLumes) {
    # ultimo resultado
    $ultimoResultadoHectareas{$lume} = '';

    # keys invariables
    print sprintf("%s $SEPARADOR %s $SEPARADOR %s", $lume, $dataLumes{$lume}{concello}, $dataLumes{$lume}{estado});

    # keys que hai que sacar ordeadas, as fechas
    foreach my $dia (@sorted_keys_asc) {
        # para Flourish quitamos puntos de milleiros
        $dataLumes{$lume}{$dia} =~ s/\.//g if($dataLumes{$lume}{$dia});
        
        if($conservar_lumes) {
            $ultimoResultadoHectareas{$lume} = $dataLumes{$lume}{$dia} if($dataLumes{$lume}{$dia});
        }

        print sprintf("$SEPARADOR %s", $dataLumes{$lume}{$dia} || $ultimoResultadoHectareas{$lume});
    }
    print "\n";     #salto de linha final
}


1;