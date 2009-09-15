	##################################################
    ## this class is a factory of models to the     ##
    ## main                                         ##
    ##################################################
    package ModelFactory;
    use strict;
    use warnings;
	use MainParameters;
    use MainModelJC69;
	use MainModelKimura;
    
    ## give a instance of a subclass of Model       ##
    sub getInstance {
    	my $parameters = Parameters::getInstance;
    	my $model = $parameters->parameter("MODEL");
    	
    	if($model eq 'jc'){
    		return new JC69;
    	}else {
    		return new K2P;
    	}
    	# acrescentar aqui outros modelos
    }
    
    1;