package parseador;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    parsearConcelloMaisParroquia
    parseaFecha
    parseaHectareas
);


# formatos: concello-parroquia; concello1-parroquia1 e concello2-parroquia2; concello1 (parroquia1 e parroquia2) e concello2-parroquia3; e algún máis
#   por comodidade so vou devolver o primeiro concelho!
sub parsearConcelloMaisParroquia{
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


# ToDo
# recolhemos data, a que sempre está
#   Data de actualización: <span class="texto-bold">19/08/2025</span>
# outras:
#    "datePublished": "2025-08-19T21:09:56+02:00"
#   <meta name="content_date" content='03/08/2025' xml:lang="gl" lang="gl">
sub parseaFecha{
    my $html_content = $_[0];

    if($html_content =~ /Data de actualización: <span class="texto-bold">(.*)<\/span>/) {
        return $1;
    }

    die "Erro recolhendo fecha!";
}

#
sub parseaHectareas{
    my $line = $_[0];

    # ás veces hai comas
    if($line =~ /([\d\.\,]+) hectáreas?/gm) {
        print "Hectareas: [$1]\n";
        return $1;
    }
}

#
sub parseaConcelloParroquia{
    my $concelloParroquia = $_[0];

    # Vilardevós-Terroso, Activada Situación 2
    $concelloParroquia =~ s/(.*), .*/$1/;

    # Monfero-Queixeiro. Afecta o Parque das Fragas do Eume
    $concelloParroquia =~ s/(.*)\. .*/$1/;

    return $concelloParroquia;
}


# parseador xeral, para non repetir código nos distintos parseadores e que só se preocupen do output
#   sempre devolve unha referencia ao hash
sub parseadorXeral{
    my $html_content = $_[0];

    my %data;

    # recorremos linha a linha e cando cheguemos a activos/controlados/etc, colhemos concelho e despois as hectareas na seguinte linha
    my @lines = split /\n/, $html_content;

    my @dataTmp;    # para conservar $lume na seguinte linha

    my $activo = undef;
    foreach my $line (@lines) {
        # hectareas, seguinte linha
        if($activo) {
            $data{$dataTmp[0]}{hectareas} = parseaHectareas($line);

            $activo = undef;         # "reseteamos"
        }

        # ACTIVOS
        if(my @matches = $line =~ /(Activo|Controlado|Estabilizado|Extinguido) (.*?)<\/(strong|h2)/gm) {
            $activo = 1;

            my $tipo = $matches[0];
            my $concelloParroquia = parseaConcelloParroquia($matches[1]);
            print "concelloParroquia: [$concelloParroquia]\n";

            print "tipo: [$tipo]  -- ";
            my $lume = parsearConcelloMaisParroquia($concelloParroquia);
            print "lume: [$lume]\n";

            $data{$concelloParroquia} = {'concello' => $lume, 'estado' => $tipo};  # concello vai ser o output (podería haber 2 no mesmo...)
            $dataTmp[0] = $concelloParroquia;
        }
    }

    return \%data;
}



1; 