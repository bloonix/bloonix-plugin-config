CONFIG=Makefile.config

include $(CONFIG)

default: build

build:

	cp bin/bloonix-load-plugins.in bin/bloonix-load-plugins;
	sed -i "s!@@PERL@@!$(PERL)!g" bin/bloonix-load-plugins;
	sed -i "s!@@CONFDIR@@!$(CONFDIR)!g" bin/bloonix-load-plugins;

	# Perl
	if test "$(WITHOUT_PERL)" = "0" ; then \
		set -e; cd perl; \
		$(PERL) Build.PL installdirs=$(PERL_INSTALLDIRS); \
		$(PERL) Build; \
	fi;

test:

	if test "$(WITHOUT_PERL)" = "0" ; then \
		set -e; cd perl; \
		$(PERL) Build test; \
	fi;

install:

	if test ! -e "$(PREFIX)/bin" ; then \
		mkdir -p "$(PREFIX)/bin"; \
	fi;

	cp -a bin/bloonix-create-plugin "$(PREFIX)/bin/";
	chmod 755 "$(PREFIX)/bin/bloonix-create-plugin";

	if test ! -e "$(PREFIX)/lib/bloonix/etc/plugins/import" ; then \
		mkdir -p "$(PREFIX)/lib/bloonix/etc/plugins/import"; \
	fi;

	cd plugins; for dir in * ; do \
		cp -a $$dir $(PREFIX)/lib/bloonix/etc/plugins/import/; \
		chmod 755 $(PREFIX)/lib/bloonix/etc/plugins/import/$$dir; \
		chmod 644 $(PREFIX)/lib/bloonix/etc/plugins/import/$$dir/*; \
	done;

	./install-sh -d -m 0755 $(PREFIX)/bin;
	./install-sh -c -m 0755 bin/bloonix-load-plugins $(PREFIX)/bin/bloonix-load-plugins;

	if test "$(WITHOUT_PERL)" = "0" ; then \
		set -e; cd perl; $(PERL) Build install; $(PERL) Build realclean; \
	fi;

clean:

	if test "$(WITHOUT_PERL)" = "0" ; then \
		cd perl; \
		if test -e "Makefile" ; then \
			$(PERL) Build clean; \
		fi; \
	fi;

