package Log::ger::Plugin::Multisets;

use strict;
use warnings;

use Log::ger ();

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta { +{
    v => 2,
} }

sub get_hooks {
    my %plugin_conf = @_;

    die "Please specify at least one of ".
        "logger_sub_prefixes|level_checker_sub_prefixes|logger_method_prefixes|level_checker_method_prefixes"
        unless
        $plugin_conf{logger_sub_prefixes} ||
        $plugin_conf{level_checker_sub_prefixes} ||
        $plugin_conf{logger_method_prefixes} ||
        $plugin_conf{level_checker_method_prefixes};

    return {
        create_routine_names => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                my $levels = [keys %Log::ger::Levels];

                my $routine_names = {};
                for my $key0 (qw(logger_sub level_checker_sub logger_method level_checker_method)) {
                    my $routine_names_key = "${key0}s";
                    my $plugin_conf_key = "${key0}_prefixes";
                    $routine_names->{$routine_names_key} = [];
                    next unless $plugin_conf{$plugin_conf_key};
                    for my $prefix (keys %{ $plugin_conf{$plugin_conf_key} }) {
                        my $init_args = $plugin_conf{$plugin_conf_key}{$prefix};
                        push @{ $routine_names->{$routine_names_key} }, map
                            { ["${prefix}$_", $_, undef, $init_args] }
                            @$levels;
                    }
                }

                [$routine_names, 1];
            }],
    };
}

1;
# ABSTRACT: Create multiple sets of logger routines, each set with its own init arguments

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

Instead of having to resort to OO style to log to different categories:

 use Log::ger ();

 my $access_log = Log::ger->get_logger(category => 'access');
 my $error_log  = Log::ger->get_logger(category => 'error');

 $access_log->info ("goes to access log");
 $access_log->warn ("goes to access log");
 $error_log ->warn ("goes to error log");
 $error_log ->debug("goes to error log");
 ...

you can instead:

 use Log::ger::Plugin Multisets => (
     logger_sub_prefixes => {
         # prefix  => per-target conf
         log_      => {category=>'error' }, # or undef, to use the default init args (including category)
         access_   => {category=>'access'},
     },
     level_checker_sub_prefixes => {
         # prefix  => per-target conf
         is_        => {category=>'error' },
         access_is_ => {category=>'access'},
     },
 );
 use Log::ger;

 access_info "goes to access log";
 access_warn "goes to access log";
 log_warn    "goes to error log";
 log_debug   "goes to error log";
 ...


=head1 DESCRIPTION

This plugin lets you create multiple sets of logger subroutines, each set with
its own init arguments. This can be used e.g. when you want to log to different
categories without resorting to OO style.


=head1 CONFIGURATION

=head2 logger_sub_prefixes

Hash.

=head2 level_checker_sub_prefixes

Hash.

=head2 logger_method_prefixes

Hash.

=head2 level_checker_method_prefixes

Hash.


=head1 SEE ALSO

L<Log::ger>
