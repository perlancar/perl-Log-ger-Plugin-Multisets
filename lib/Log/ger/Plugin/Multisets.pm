package Log::ger::Plugin::Multisets;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Log::ger ();

sub get_hooks {
    my %conf = @_;

    die "Please specify at least one of ".
        "log_sub_prefixes|is_sub_prefixes|log_method_prefixes|is_method_prefixes"
        unless
        $conf{log_sub_prefixes} ||
        $conf{is_sub_prefixes} ||
        $conf{log_method_prefixes} ||
        $conf{is_method_prefixes};

    return {
        create_routine_names => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_;

                my $levels = [keys %Log::ger::Levels];

                my $routine_names = {};
                for my $key0 (qw(log_sub is_sub log_method is_method)) {
                    my $routine_names_key = "${key0}s";
                    my $conf_key = "${key0}_prefixes";
                    $routine_names->{$routine_names_key} = [];
                    next unless $conf{$conf_key};
                    for my $prefix (keys %{ $conf{$conf_key} }) {
                        my $init_args = $conf{$conf_key}{$prefix};
                        push @{ $routine_names->{$routine_names_key} }, map
                            { ["${prefix}_$_", $_, undef, $init_args] }
                            @$levels;
                    }
                }

                [$routine_names, 1];
            }],
    };
}

1;
# ABSTRACT: Create multiple sets of logger routines

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

Instead of having to resort to OO style to log to different categories:

 use Log::ger ();

 my $access_log = Log::ger->get_logger('access');
 my $error_log  = Log::ger->get_logger('error');

 $access_log->info ("goes to access log");
 $access_log->warn ("goes to access log");
 $error_log ->warn ("goes to error log");
 $error_log ->debug("goes to error log");
 ...

you can instead:

 use Log::ger::Plugin Multisets => (
     log_sub_prefixes => {
         # prefix  => category
         log_      => 'error',
         access_   => 'access',
     },
     is_sub_prefixes => {
         # prefix  => category
         is_       => 'error',
         access_is => 'access',
     },
 );
 use Log::ger;

 access_info "goes to access log";
 access_warn "goes to access log";
 log_warn    "goes to error log";
 log_debug   "goes to error log";
 ...


=head1 DESCRIPTION

This plugin lets you create multiple sets of logger subroutines if you want to
log to different categories without resorting to OO style.


=head1 CONFIGURATION

=head2 log_sub_prefixes

Hash.

=head2 is_sub_prefixes

Hash.

=head2 log_method_prefixes

Hash.

=head2 is_method_prefixes

Hash.


=head1 SEE ALSO

L<Log::ger>
