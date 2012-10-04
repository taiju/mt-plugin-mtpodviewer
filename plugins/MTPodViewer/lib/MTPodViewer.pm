package MTPodViewer;
use strict;

use base qw( MT::App );

use MT::Util;
use Pod::Simple::XHTML;
use File::Find;

sub init_request {
    my $app = shift;
    my $plugin = MT->component('MTPodViewer');
    $app->SUPER::init_request(@_);
    $app->add_methods(
        view         => \&view,
        partial      => \&partial,
        partial_text => \&partial_text,
    );
    $app->{default_mode}    = 'view';
    $app->{requires_login}  = $plugin->get_config_value('requires_login', 'system');
    $app->{__pod_files}     = _pod_files($app->mt_dir . '/lib');
}

sub view {
    my $app       = shift;
    my $files     = $app->{__pod_files};
    my $key       = $app->param('key') || 'mt';
    my $app_path  = $app->app_path;
    $app_path =~ s/\/$//;
    my $script    = $app->script;
    my $app_static_path = $app->static_path . 'plugins/MTPodViewer';
    my $html = $app->partial($key);
    $app->build_page('viewer.tmpl', {
        html => $html,
        app_static_path => $app_static_path,
        app_path => $app_path,
        script => $script,
        data_source => MT::Util::to_json([keys %{$files}]),
    });
}

sub partial {
    my $app       = shift;
    my $key       = shift;
    my $files     = $app->{__pod_files};
    my $psx       = Pod::Simple::XHTML->new;
    my $html      = '';
    $psx->output_string(\$html);
    $psx->parse_file($files->{$key});
    $html =~ s|<a href=".+?">(.+?)</a>|<b>$1</b>|g;
    my ($body) = $html =~ m|<body>(.+?)</body>|sm;
    $body;
}

sub partial_text {
    my $app = shift;
    my $key = $app->param('key');
    my $html = $app->partial($key);
    $html;
}

sub _pod_files {
    my $path  = shift;
    my @files;
    find({
        follow_skip => 2,
        no_chdir    => 1,
        wanted      => sub {
            my $psx = Pod::Simple::XHTML->new;
            my $html = '';
            return unless $_ =~ /\.p(od|m)$/;
            $psx->output_string(\$html);
            $psx->parse_file($File::Find::name);
            my ($body) = $html =~ m|<body>(.+?)</body>|sm;
            $body =~ s/\s+//g;
            return unless $body;
            push @files, $File::Find::name;
        },
    }, $path);
    _pod_files_map($path, [@files]);
}

sub _pod_files_map {
    my ($mt_lib_path, $files) = @_;
    +{ map {
        my $simple = $_;
        $simple =~ s/$mt_lib_path\///;
        $simple =~ s/\//-/g;
        $simple =~ s/^MT-//;
        $simple =~ s/\.p(od|m)$//;
        { lc $simple => $_ };
    } @$files };
}

sub cgi_path {
    my $path = shift->app_path;
    $path =~ s|/$||;
    $path;
}

sub script {
    'mtpodviewer.cgi';
}

1;
