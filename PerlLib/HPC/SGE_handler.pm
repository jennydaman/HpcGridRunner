package HPC::SGE_handler;

use strict;
use warnings;
use base qw(HPC::Base_handler);
use Carp;
use Cwd;
use Data::Dumper;

####
sub new {
    my $packagename = shift;
    my $config_obj = shift;
    
    unless (ref $config_obj) {
        confess "Error, need config obj as param";
    }
    
    
    my $self = {config => $config_obj};
    
    bless($self, $packagename);

    return($self);
}

####
sub submit_job_to_grid {
    my $self = shift;
    my $shell_script = shift;

    unless (-s $shell_script) {
        confess "Error, need shell script to submit as parameter.";
    }

    ## submit the command, do any additional job administration as required, such as capturing job ID

    my $cmd = $self->{config}->get_value("GRID", "cmd") or confess "Error, need cmd from config: " . Dumper($self->{config});
    
    $cmd .= " -e $shell_script.stderr -o $shell_script.stdout $shell_script 2>&1 ";
    
    
    my $job_id_text = `$cmd`;
    #print STDERR "\nSGE: $job_id_text\n";
    
    my $ret = $?;
    

    if ($ret) {
        print STDERR "FARMIT failed to accept job: [$cmd]\n (ret $ret)\n$job_id_text\n";
        return(-1);
    }
    else {
    
        ## job submitted just fine.
        
        ## get the job ID and log it:
        if ($job_id_text =~ /Your job (\d+) /) {
            my $job_id = $1;
            return($job_id);
        }
        else {
            confess "Fatal error, couldn't extract Job ID from submission text: $job_id_text"; 
        }
    }
    

}

####
sub job_running_or_pending_on_grid {
    my $self = shift;
    my $job_id = shift;

    unless (defined($job_id)) {
        confess "Error, need job ID as parameter";
    }
    
    # print STDERR "Polling grid to check status of job: $job_id\n";
    
    my $response = `qstat`;
    #print STDERR "Response:\n$response\n";

    foreach my $line (split(/\n/, $response)) {
        $line =~ s/^\s+//;
        my @x = split(/\s+/, $line);
        
        if ($x[0] eq $job_id) {
            my $state = $x[4];
            
            $self->{job_id_to_submission_time}->{$job_id} = time();
            return($state);
            
        }
    }
    
    print STDERR "-warning, no record of job_id $job_id via qstat ... may be transitioning to finished.\n";
    return undef; # no status info

}    


1; #EOM
