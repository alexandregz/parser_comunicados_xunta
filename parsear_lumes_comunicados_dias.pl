# Igual que parsear_lumes_comunicados.pl pero vai engadindo resultados por días, creando un hash de todos os lumes como base

use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;
use Data::Dumper;


die "Uso: perl $0 URL \n" unless($ARGV[0]);
my $url = $ARGV[0];

# initialize the HTTP client
my $http = HTTP::Tiny->new();
# Retrieve the HTML code of the page to scrape
my $response = $http->get($url);
my $html_content = $response->{content};

# print $html_content;
# die;

    
# hash final cos datos
my %data;


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


# # ToDo
# # recolhemos data, a que sempre está
# #   Data de actualización: <span class="texto-bold">19/08/2025</span>
# # outras:
# #    "datePublished": "2025-08-19T21:09:56+02:00"
# #   <meta name="content_date" content='03/08/2025' xml:lang="gl" lang="gl">
# if($html_content =~ /Data de actualización: <span class="texto-bold">(.*)<\/span>/) {
#     die "data: $1";
# }



# recorremos linha a linha e cando cheguemos a activos/controlados/etc, colhemos concelho e despois as hectareas na seguinte linha
my @lines = split /\n/, $html_content;


my @dataTmp;    # para conservar $lume na seguinte linha

my $activo = undef;
foreach my $line (@lines) {
    # hectareas, seguinte linha
    if($activo) {
        # ás veces hai comas
        if(my @matches = $line =~ /([\d\.\,]+) hectáreas?/gm) {
            # print "Hectareas: [$1]\n";
            $data{$dataTmp[0]}{hectareas} = $1;
        }
        $activo = undef;         # "reseteamos"
    }


    # ACTIVOS
    if(my @matches = $line =~ /(Activo|Controlado|Estabilizado|Extinguido) (.*?)<\/(strong|h2)/gm) {
        $activo = 1;

        my $tipo = $matches[0];
        my $concelloParroquia = $matches[1];
        print "concelloParroquia: [$concelloParroquia]\n";

        # Vilardevós-Terroso, Activada Situación 2
        $concelloParroquia =~ s/(.*), .*/$1/;

        # Monfero-Queixeiro. Afecta o Parque das Fragas do Eume
        $concelloParroquia =~ s/(.*)\. .*/$1/;


        # print "tipo: [$tipo]  -- ";
        my $lume = _parsearConcelloMaisParroquia($concelloParroquia);
        # print "lume: [$lume]\n";

        $data{$concelloParroquia} = {'concello' => $lume, 'estado' => $tipo};  # concello vai ser o output (podería haber 2 no mesmo...)
        $dataTmp[0] = $concelloParroquia;
    }
}

# print Dumper \%data;

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