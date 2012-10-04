use inc::Module::Install;
name 'MTPodViewer';
version '0.1';

requires 'Pod::Simple::XHTML' => 3.23;
requires 'Pod::Escapes' => 1.04;
requires 'File::Find' => 1.20;

WriteAll;
