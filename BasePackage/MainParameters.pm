	##################################################
	## that class stores necessary parameters to	##
	## all class of the distance's modulate of		##
	## GRAFU										##
	##################################################

	package Parameters;
	use strict;
	use warnings;

	##################################################
	## the object constructor						##
	##################################################
    
	my $_new = sub {

        	my $self  = {};

        	$self->{"TYPE"} 	= undef;
        	$self->{"INPUT"} 	= undef;
        	$self->{"QSPEC"}	= undef;
		$self->{"ALPHA"}	= undef;
		$self->{"GAMMA"}	= undef;
        	$self->{"FREQUE"}	= undef;
        	$self->{"OUTPUT"} 	= undef;
        	$self->{"PREFERENCE"}	= undef;
        	$self->{"LDIFFERENCE"}	= undef;
        	$self->{"ADDICTIVITY"}	= undef;
        	$self->{"SEQUENTIAL"}	= undef;
        	$self->{"LETTER"}	= undef;
        	$self->{"WEIGHT"} 	= undef;
        	$self->{"RATIO"} 	= undef;
        	$self->{"ISITE"}	= undef;# fraction
        	$self->{"MODEL"}	= undef;
        	$self->{"NAMES"}	= undef;
		$self->{"TEMP"}		= undef;
		$self->{"PWD"}		= undef;
		$self->{"CATEGORIES"}	= undef;

		bless($self);

		return $self;

	};
    
	##################################################
	## class attribute								##
	##################################################
	
	my $instance = undef;
	    
	##################################################
	## methods to access data						##
	##################################################

	sub parameter {
  	 	my $self = shift;
       	if (@_ == 2) {  $self->{$_[0]}  = $_[1] }
       	return $self->{$_[0]};
	}
    
   	sub configure {
   		my $self = shift;

	    	while(@_){
	    		my $indice = shift;
	    		$self->{$indice} = shift; 
	    	}

		# Tratamento de GAMMA
		if(defined $self->{"ALPHA"}){

			# A opção gamma desabilita a opção categorias
			if(defined $self->{"CATEGORIES"}){
				print "Input error: a opcao gamma desabilita a opcao de categorias\n";
				exit;
			}

			# Faz o reconhecimento dos argumentos de ALPHA e ISITE (se possuir)
			if($self->{"ALPHA"} <= 0){
				print "Argumento invalido: ALPHA deve ser positivo\n";
				exit;
			}
			if(defined $self->{"ISITE"}){
				if($self->{"ISITE"} <= 0 || $self->{"ISITE"} >= 1){
					print "Argumento invalido: ISITE deve ser um numero entre 0 e 1\n";
					exit;
				}
				$self->{"GAMMA"} = 2;
			}
			else{ $self->{"GAMMA"} = 1 }
		}
		elsif(defined $self->{"ISITE"}){
			print "Input error: ISITE so pode ser usado se ALPHA for definido\n";
			exit;
		}
		else{ $self->{"GAMMA"} = 0 }

		# configura parametros default para parametros não setados ou incorretos
	#	$self->{"GAMMA"} = (!defined $self->{"ALPHA"})? 0 : #opcao "n"
	#		   ((defined $self->{"ISITE"}) ? 2 : 1);    	#opcao "gi" ou "y"
		my $type = $self->{"TYPE"};
       	$self->{"TYPE"}	 = "dna" if(!defined $type or
        						($type ne "dna"   and
        					 	 $type ne "prot"));
        my $preference = $self->{"PREFERENCE"};
        $self->{"PREFERENCE"}	= "a" if(!defined $preference or
        								($preference ne "a"  and
        					 			 $preference ne "ta" and
        					 			 $preference ne "t"));
	defined $self->{"MODEL"} or $self->{"MODEL"} = "kimura";
	defined $self->{"INPUT"} or die "ERRO: Esqueceu de passar o arquivo de entrada.\n";
        defined $self->{"OUTPUT"} or die "ERRO: Esqueceu de passar o arquivo de saida.\n";

        # Demais Parametros:
        # $self->{"ALPHA"}	 	 = MainAbstract trata default;
        # $self->{"ISITE"}	 	 = MainAbstract trata default;
	    # $self->{"QSPEC"}	 	 = setado por Converter;
	    # $self->{"LDIFFERENCE"} = usado somente por Main;
	    # $self->{"ADDICTIVITY"} = usado somente por Main;
        # $self->{"SEQUENTIAL"}  = setado por Converter;
	    # $self->{"LETTER"}	 	 = setado por Converter;
	    # $self->{"WEIGHT"} 	 = MainAbstract trata default;
	    # $self->{"RATIO"} 	 	 = 2.0 default no MainAbstract;
	    # $self->{"MODEL"}	 	 = F84 default no MainAbstract;
	    # $self->{"NAMES"}	 	 = usado somente por Converter;
	    # $self->{"TEMP"}	 	 = setado no Run;
		# $self->{"PWD"}	 	 = setado no Run;
	}
    
	sub getInstance {
    	if(!defined $instance) {
    		my $self = shift;
    		$instance = $self->$_new();
    	}
    	return $instance;
    }

    1;
	## main e converter mexem aki
