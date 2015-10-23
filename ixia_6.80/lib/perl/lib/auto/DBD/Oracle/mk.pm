$dbd_oracle_mm_opts = {
                        'META_MERGE' => {
                                          'build_requires' => {
                                                                'DBI' => '1.51',
                                                                'ExtUtils::MakeMaker' => 0,
                                                                'Test::Simple' => '0.90'
                                                              },
                                          'resources' => {
                                                           'repository' => {
                                                                             'url' => 'git://github.com/yanick/DBD-Oracle.git',
                                                                             'web' => 'http://github.com/yanick/DBD-Oracle/tree',
                                                                             'type' => 'git'
                                                                           },
                                                           'bugtracker' => {
                                                                             'mailto' => 'bug-dbd-oracle at rt.cpan.org',
                                                                             'web' => 'http://rt.cpan.org/Public/Dist/Display.html?Name=DBD-Oracle'
                                                                           },
                                                           'homepage' => 'http://search.cpan.org/dist/DBD-Oracle'
                                                         },
                                          'configure_requires' => {
                                                                    'DBI' => '1.51'
                                                                  }
                                        },
                        'INC' => '-I/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2/sdk/include -I/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/auto/DBI',
                        'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                        'OBJECT' => '$(O_FILES)',
                        'LICENSE' => 'perl',
                        'clean' => {
                                     'FILES' => 'xstmp.c Oracle.xsi dll.base dll.exp sqlnet.log libOracle.def mk.pm DBD_ORA_OBJ.*'
                                   },
                        'NAME' => 'DBD::Oracle',
                        'dist' => {
                                    'DIST_DEFAULT' => 'clean distcheck disttest tardist',
                                    'SUFFIX' => 'gz',
                                    'PREOP' => '$(MAKE) -f Makefile.old distdir',
                                    'COMPRESS' => 'gzip -v9'
                                  },
                        'PREREQ_PM' => {
                                         'DBI' => '1.51'
                                       },
                        'DIR' => [],
                        'LIBS' => [
                                    '-L/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2 -lclntsh'
                                  ],
                        'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3\\" -DORA_OCI_102 -DORA_OCI_112',
                        'AUTHOR' => 'Tim Bunce (dbi-users@perl.org)',
                        'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                        'dynamic_lib' => {
                                           'OTHERLDFLAGS' => ''
                                         }
                      };
$dbd_oracle_mm_self = bless( {
                               'ABSTRACT' => 'Oracle database driver for the DBI module',
                               'INST_STATIC' => '$(INST_ARCHAUTODIR)/$(BASEEXT)$(LIB_EXT)',
                               'NAME' => 'DBD::Oracle',
                               'INSTALLVENDORARCH' => '',
                               'PARENT_NAME' => 'DBD',
                               'PL_FILES' => {},
                               'ZIPFLAGS' => '-r',
                               'INSTALLDIRS' => 'perl',
                               'TARFLAGS' => 'cvf',
                               'OBJ_EXT' => '.o',
                               'COMPRESS' => 'gzip --best',
                               'VERSION_MACRO' => 'VERSION',
                               'LD' => 'gcc',
                               'PERL' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/bin/perl-static',
                               'DESTINSTALLSCRIPT' => '$(DESTDIR)$(INSTALLSCRIPT)',
                               'INSTALLHTMLDIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/html',
                               'MOD_INSTALL' => '$(ABSPERLRUN) -MExtUtils::Install -e \'install([ from_to => {@ARGV}, verbose => \'\\\'\'$(VERBINST)\'\\\'\', uninstall_shadows => \'\\\'\'$(UNINST)\'\\\'\', dir_mode => \'\\\'\'$(PERM_DIR)\'\\\'\' ]);\' --',
                               'SO' => 'so',
                               'VENDORPREFIX' => '',
                               'DLSRC' => 'dl_dlopen.xs',
                               'TRUE' => 'true',
                               'VENDORLIBEXP' => '',
                               'USEMAKEFILE' => '-f',
                               'INSTALLSITEARCH' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/lib',
                               'INSTALLARCHLIB' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib',
                               'INSTALLMAN1DIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/man/man1',
                               'INST_AUTODIR' => '$(INST_LIB)/auto/$(FULLEXT)',
                               'RESULT' => [
                                             '# This Makefile is for the DBD::Oracle extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.66 (Revision: 66600) from the contents of
# Makefile.PL. Don\'t edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: (q[INSTALLDIRS=perl])
#
',
                                             '#   MakeMaker Parameters:
',
                                             '#     ABSTRACT_FROM => q[lib/DBD/Oracle.pm]',
                                             '#     AUTHOR => [q[Tim Bunce (dbi-users@perl.org)]]',
                                             '#     BUILD_REQUIRES => {  }',
                                             '#     CONFIGURE_REQUIRES => {  }',
                                             '#     DEFINE => q[ -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3\\" -DORA_OCI_102 -DORA_OCI_112]',
                                             '#     DIR => []',
                                             '#     INC => q[-I/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2/sdk/include -I/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/auto/DBI]',
                                             '#     LIBS => [q[-L/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2 -lclntsh]]',
                                             '#     LICENSE => q[perl]',
                                             '#     META_MERGE => { build_requires=>{ DBI=>q[1.51], ExtUtils::MakeMaker=>q[0], Test::Simple=>q[0.90] }, resources=>{ repository=>{ url=>q[git://github.com/yanick/DBD-Oracle.git], web=>q[http://github.com/yanick/DBD-Oracle/tree], type=>q[git] }, bugtracker=>{ mailto=>q[bug-dbd-oracle at rt.cpan.org], web=>q[http://rt.cpan.org/Public/Dist/Display.html?Name=DBD-Oracle] }, homepage=>q[http://search.cpan.org/dist/DBD-Oracle] }, configure_requires=>{ DBI=>q[1.51] } }',
                                             '#     NAME => q[DBD::Oracle]',
                                             '#     OBJECT => q[$(O_FILES)]',
                                             '#     PREREQ_PM => { DBI=>q[1.51] }',
                                             '#     TEST_REQUIRES => {  }',
                                             '#     VERSION_FROM => q[lib/DBD/Oracle.pm]',
                                             '#     clean => { FILES=>q[xstmp.c Oracle.xsi dll.base dll.exp sqlnet.log libOracle.def mk.pm DBD_ORA_OBJ.*] }',
                                             '#     dist => { DIST_DEFAULT=>q[clean distcheck disttest tardist], SUFFIX=>q[gz], PREOP=>q[$(MAKE) -f Makefile.old distdir], COMPRESS=>q[gzip -v9] }',
                                             '#     dynamic_lib => { OTHERLDFLAGS=>q[] }',
                                             '
# --- MakeMaker post_initialize section:'
                                           ],
                               'DESTINSTALLARCHLIB' => '$(DESTDIR)$(INSTALLARCHLIB)',
                               'LIB_EXT' => '.a',
                               'UMASK_NULL' => 'umask 0',
                               'LINKTYPE' => 'dynamic',
                               'DESTINSTALLSITEMAN3DIR' => '$(DESTDIR)$(INSTALLSITEMAN3DIR)',
                               'MAN1EXT' => '1',
                               'NOECHO' => '@',
                               'INSTALLVENDORMAN3DIR' => '',
                               'TO_UNIX' => '$(NOECHO) $(NOOP)',
                               'DEV_NULL' => '> /dev/null 2>&1',
                               'INSTALLSITESCRIPT' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/bin',
                               'INST_SCRIPT' => 'blib/script',
                               'DISTNAME' => 'DBD-Oracle',
                               'INSTALLBIN' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/bin',
                               'MACROEND' => '',
                               'MAKEFILE' => 'Makefile',
                               'PERM_RWX' => 755,
                               'SITELIBEXP' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/lib',
                               'LIBPERL_A' => 'libperl.a',
                               'DESTINSTALLHTMLDIR' => '$(DESTDIR)$(INSTALLHTMLDIR)',
                               'CCDLFLAGS' => '-Wl,-E -Wl,-rpath,/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/CORE',
                               'DESTINSTALLBIN' => '$(DESTDIR)$(INSTALLBIN)',
                               'FULLPERLRUN' => '$(FULLPERL)',
                               'PERL_CORE' => 0,
                               'VENDORARCHEXP' => '',
                               'INSTALLSITELIB' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/lib',
                               'ABSPERLRUNINST' => '$(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'AR' => 'ar',
                               'ABSPERLRUN' => '$(ABSPERL)',
                               'EXPORT_LIST' => '',
                               'LDFROM' => '$(OBJECT)',
                               'NAME_SYM' => 'DBD_Oracle',
                               'PERL_MALLOC_DEF' => '-DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc',
                               'PMLIBDIRS' => [
                                                'lib'
                                              ],
                               'PERL_LIB' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib',
                               'SITEARCHEXP' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/lib',
                               'PERLRUN' => '$(PERL)',
                               'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3\\" -DORA_OCI_102 -DORA_OCI_112',
                               'TAR' => 'tar',
                               'XS' => {
                                         'Oracle.xs' => 'Oracle.c'
                                       },
                               'INST_ARCHAUTODIR' => '$(INST_ARCHLIB)/auto/$(FULLEXT)',
                               'FULL_AR' => '/usr/bin/ar',
                               'DOC_INSTALL' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e \'perllocal_install\' --',
                               'DESTINSTALLSITEHTMLDIR' => '$(DESTDIR)$(INSTALLSITEHTMLDIR)',
                               'PERLRUNINST' => '$(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'DESTINSTALLMAN1DIR' => '$(DESTDIR)$(INSTALLMAN1DIR)',
                               'ECHO_N' => 'echo -n',
                               'LIBC' => '/lib/libc-2.5.so',
                               'OBJECT' => '$(O_FILES)',
                               'DESTINSTALLVENDORHTMLDIR' => '$(DESTDIR)$(INSTALLVENDORHTMLDIR)',
                               'DESTINSTALLVENDORLIB' => '$(DESTDIR)$(INSTALLVENDORLIB)',
                               'MM_Unix_VERSION' => '6.66',
                               'EXE_EXT' => '',
                               'PERL_ARCHIVE' => '',
                               'CP' => 'cp',
                               'INSTALLPRIVLIB' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib',
                               'MACROSTART' => '',
                               'INSTALLVENDORMAN1DIR' => '',
                               'MAKEMAKER' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/ExtUtils/MakeMaker.pm',
                               'FALSE' => 'false',
                               'MAKE' => 'make',
                               'WARN_IF_OLD_PACKLIST' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e \'warn_if_old_packlist\' --',
                               'MAKE_APERL_FILE' => 'Makefile.aperl',
                               'CHMOD' => 'chmod',
                               'DESTINSTALLSITEBIN' => '$(DESTDIR)$(INSTALLSITEBIN)',
                               'DESTINSTALLVENDORBIN' => '$(DESTDIR)$(INSTALLVENDORBIN)',
                               'PREOP' => '$(NOECHO) $(NOOP)',
                               'DESTINSTALLVENDORARCH' => '$(DESTDIR)$(INSTALLVENDORARCH)',
                               'PERM_DIR' => 755,
                               'VERBINST' => 0,
                               'CCCDLFLAGS' => '-fPIC',
                               'DESTINSTALLVENDORSCRIPT' => '$(DESTDIR)$(INSTALLVENDORSCRIPT)',
                               'NOOP' => '$(TRUE)',
                               'ZIP' => 'zip',
                               'PM' => {
                                         'lib/DBD/Oracle.pm' => 'blib/lib/DBD/Oracle.pm',
                                         'lib/DBD/Oracle/Troubleshooting/Win32.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Win32.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Vms.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Vms.pod',
                                         'lib/DBD/Oracle/Object.pm' => 'blib/lib/DBD/Oracle/Object.pm',
                                         'lib/DBD/Oracle/Troubleshooting/Sun.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Sun.pod',
                                         'mk.pm' => '$(INST_LIB)/DBD/mk.pm',
                                         'lib/DBD/Oracle/Troubleshooting/Cygwin.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Cygwin.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Win64.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Win64.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Macos.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Macos.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Linux.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Linux.pod',
                                         'lib/DBD/Oracle/Troubleshooting/Aix.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Aix.pod',
                                         'lib/DBD/Oracle/Troubleshooting.pod' => 'blib/lib/DBD/Oracle/Troubleshooting.pod',
                                         'lib/DBD/Oracle/GetInfo.pm' => 'blib/lib/DBD/Oracle/GetInfo.pm',
                                         'lib/DBD/Oracle/Troubleshooting/Hpux.pod' => 'blib/lib/DBD/Oracle/Troubleshooting/Hpux.pod'
                                       },
                               'SHELL' => '/bin/sh',
                               'DLBASE' => '$(BASEEXT)',
                               'POSTOP' => '$(NOECHO) $(NOOP)',
                               'AUTHOR' => [
                                             'Tim Bunce (dbi-users@perl.org)'
                                           ],
                               'INSTALLSITEHTMLDIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/html',
                               'DESTINSTALLSITEMAN1DIR' => '$(DESTDIR)$(INSTALLSITEMAN1DIR)',
                               'INST_MAN3DIR' => 'blib/man3',
                               'BSLOADLIBS' => '',
                               'MKPATH' => '$(ABSPERLRUN) -MExtUtils::Command -e \'mkpath\' --',
                               'INSTALLSITEBIN' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/bin',
                               'INST_BIN' => 'blib/bin',
                               'ARGS' => {
                                           'PREREQ_PM' => $dbd_oracle_mm_opts->{'PREREQ_PM'},
                                           'DIR' => $dbd_oracle_mm_opts->{'DIR'},
                                           'INC' => '-I/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2/sdk/include -I/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/auto/DBI',
                                           'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                                           'clean' => $dbd_oracle_mm_opts->{'clean'},
                                           'LICENSE' => 'perl',
                                           'NAME' => 'DBD::Oracle',
                                           'AUTHOR' => $dbd_oracle_mm_self->{'AUTHOR'},
                                           'INSTALLDIRS' => 'perl',
                                           'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                                           'dynamic_lib' => $dbd_oracle_mm_opts->{'dynamic_lib'},
                                           'LIBS' => $dbd_oracle_mm_opts->{'LIBS'},
                                           'dist' => $dbd_oracle_mm_opts->{'dist'},
                                           'META_MERGE' => $dbd_oracle_mm_opts->{'META_MERGE'},
                                           'OBJECT' => '$(O_FILES)',
                                           'DEFINE' => ' -Wall -Wno-comment -DUTF8_SUPPORT -DORA_OCI_VERSION=\\"11.2.0.3\\" -DORA_OCI_102 -DORA_OCI_112'
                                         },
                               'DESTINSTALLSITELIB' => '$(DESTDIR)$(INSTALLSITELIB)',
                               'LDFLAGS' => ' -fstack-protector',
                               'INST_ARCHLIBDIR' => '$(INST_ARCHLIB)/DBD',
                               'UNINSTALL' => '$(ABSPERLRUN) -MExtUtils::Command::MM -e \'uninstall\' --',
                               'CONFIG' => [
                                             'ar',
                                             'cc',
                                             'cccdlflags',
                                             'ccdlflags',
                                             'dlext',
                                             'dlsrc',
                                             'exe_ext',
                                             'full_ar',
                                             'ld',
                                             'lddlflags',
                                             'ldflags',
                                             'libc',
                                             'lib_ext',
                                             'obj_ext',
                                             'osname',
                                             'osvers',
                                             'ranlib',
                                             'sitelibexp',
                                             'sitearchexp',
                                             'so',
                                             'vendorarchexp',
                                             'vendorlibexp'
                                           ],
                               'ECHO' => 'echo',
                               'INST_HTMLDIR' => 'blib/html',
                               'MV' => 'mv',
                               'C' => [
                                        'Oracle.c',
                                        'dbdimp.c',
                                        'oci8.c'
                                      ],
                               'DESTINSTALLPRIVLIB' => '$(DESTDIR)$(INSTALLPRIVLIB)',
                               'clean' => $dbd_oracle_mm_opts->{'clean'},
                               'O_FILES' => [
                                              'Oracle.o',
                                              'dbdimp.o',
                                              'oci8.o'
                                            ],
                               'LICENSE' => 'perl',
                               'OSNAME' => 'linux',
                               'PERLMAINCC' => '$(CC)',
                               'INST_BOOT' => '$(INST_ARCHAUTODIR)/$(BASEEXT).bs',
                               'RM_RF' => 'rm -rf',
                               'INSTALLVENDORHTMLDIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/html',
                               'VERSION_FROM' => 'lib/DBD/Oracle.pm',
                               'SITEPREFIX' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site',
                               'DIRFILESEP' => '/',
                               'TOUCH' => 'touch',
                               'PERM_RW' => 644,
                               'DIST_CP' => 'best',
                               'CONFIGURE_REQUIRES' => {},
                               'MM_VERSION' => '6.66',
                               'MM_REVISION' => 66600,
                               'PERL_SRC' => undef,
                               'FULLPERLRUNINST' => '$(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"',
                               'UNINST' => 0,
                               'INSTALLSITEMAN3DIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/man/man3',
                               'DESTINSTALLSITESCRIPT' => '$(DESTDIR)$(INSTALLSITESCRIPT)',
                               'META_MERGE' => $dbd_oracle_mm_opts->{'META_MERGE'},
                               'DESTINSTALLVENDORMAN1DIR' => '$(DESTDIR)$(INSTALLVENDORMAN1DIR)',
                               'PERL_ARCHLIB' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib',
                               'dist' => $dbd_oracle_mm_opts->{'dist'},
                               'INSTALLSCRIPT' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/bin',
                               'EQUALIZE_TIMESTAMP' => '$(ABSPERLRUN) -MExtUtils::Command -e \'eqtime\' --',
                               'DISTVNAME' => 'DBD-Oracle-1.58',
                               'DESTINSTALLVENDORMAN3DIR' => '$(DESTDIR)$(INSTALLVENDORMAN3DIR)',
                               'FULLPERL' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/bin/perl-static',
                               'SHAR' => 'shar',
                               'LDLOADLIBS' => '-L/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2 -lclntsh',
                               'PERL_INC' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/CORE',
                               'MAP_TARGET' => 'perl',
                               'LDDLFLAGS' => '-shared -O2 -fstack-protector',
                               'RCS_LABEL' => 'rcs -Nv$(VERSION_SYM): -q',
                               'PERLPREFIX' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------',
                               'INST_DYNAMIC' => '$(INST_ARCHAUTODIR)/$(DLBASE).$(DLEXT)',
                               'BASEEXT' => 'Oracle',
                               'PREREQ_PM' => $dbd_oracle_mm_opts->{'PREREQ_PM'},
                               'PREFIX' => '$(PERLPREFIX)',
                               'INST_LIBDIR' => '$(INST_LIB)/DBD',
                               'DESTINSTALLMAN3DIR' => '$(DESTDIR)$(INSTALLMAN3DIR)',
                               'LIBS' => $dbd_oracle_mm_opts->{'LIBS'},
                               'RM_F' => 'rm -f',
                               'SKIPHASH' => {},
                               'BOOTDEP' => '',
                               'PERL_ARCHIVE_AFTER' => '',
                               'PMLIBPARENTDIRS' => [
                                                      'lib'
                                                    ],
                               'INST_LIB' => 'blib/lib',
                               'dynamic_lib' => $dbd_oracle_mm_opts->{'dynamic_lib'},
                               'VERSION' => '1.58',
                               'HAS_LINK_CODE' => 1,
                               'DLEXT' => 'so',
                               'AR_STATIC_ARGS' => 'cr',
                               'CC' => 'gcc',
                               'CI' => 'ci -u',
                               'FULLEXT' => 'DBD/Oracle',
                               'BUILD_REQUIRES' => {},
                               'INSTALLSITEMAN1DIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/site/man/man1',
                               'RANLIB' => ':',
                               'FIXIN' => '$(ABSPERLRUN) -MExtUtils::MY -e \'MY->fixin(shift)\' --',
                               'VERSION_SYM' => '1_58',
                               'XS_VERSION_MACRO' => 'XS_VERSION',
                               'INC' => '-I/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2/sdk/include -I/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/lib/auto/DBI',
                               'INSTALLVENDORSCRIPT' => '',
                               'SUFFIX' => '.gz',
                               'MAN3EXT' => '3',
                               'TEST_REQUIRES' => {},
                               'DIR' => $dbd_oracle_mm_opts->{'DIR'},
                               'ABSPERL' => '$(PERL)',
                               'OSVERS' => '2.6.18-128.el5',
                               'INST_ARCHLIB' => 'blib/arch',
                               'DESTDIR' => '',
                               'XS_DEFINE_VERSION' => '-D$(XS_VERSION_MACRO)=\\"$(XS_VERSION)\\"',
                               'XS_VERSION' => '1.58',
                               'INSTALLVENDORBIN' => '',
                               'INSTALLMAN3DIR' => '/tmp/perl---------------------------------------------please-run-the-install-script---------------------------------------------/man/man3',
                               'ABSTRACT_FROM' => 'lib/DBD/Oracle.pm',
                               'TEST_F' => 'test -f',
                               'DESTINSTALLSITEARCH' => '$(DESTDIR)$(INSTALLSITEARCH)',
                               'DIST_DEFAULT' => 'tardist',
                               'INSTALLVENDORLIB' => '',
                               'FIRST_MAKEFILE' => 'Makefile',
                               'MAN3PODS' => {
                                               'lib/DBD/Oracle/Troubleshooting/Aix.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Aix.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Linux.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Linux.$(MAN3EXT)',
                                               'lib/DBD/Oracle/GetInfo.pm' => '$(INST_MAN3DIR)/DBD::Oracle::GetInfo.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Hpux.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Hpux.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Cygwin.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Cygwin.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Macos.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Macos.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Win64.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Win64.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Sun.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Sun.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Object.pm' => '$(INST_MAN3DIR)/DBD::Oracle::Object.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Win32.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Win32.$(MAN3EXT)',
                                               'lib/DBD/Oracle/Troubleshooting/Vms.pod' => '$(INST_MAN3DIR)/DBD::Oracle::Troubleshooting::Vms.$(MAN3EXT)',
                                               'lib/DBD/Oracle.pm' => '$(INST_MAN3DIR)/DBD::Oracle.$(MAN3EXT)'
                                             },
                               'MAKEFILE_OLD' => 'Makefile.old',
                               'EXTRALIBS' => '-L/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2 -lclntsh',
                               'INST_MAN1DIR' => 'blib/man1',
                               'LD_RUN_PATH' => '/home/gecko/build-20130920T200120-gljvaroaoy/DBD-Oracle/instantclient_11_2',
                               'H' => [
                                        'Oracle.h',
                                        'dbdimp.h',
                                        'dbivport.h',
                                        'ocitrace.h'
                                      ],
                               'DEFINE_VERSION' => '-D$(VERSION_MACRO)=\\"$(VERSION)\\"'
                             }, 'PACK001' );
