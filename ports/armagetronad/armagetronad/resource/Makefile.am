# include $(top_srcdir)/Makefile.paths

# installation destination
resourcedir=${aa_datadir}/resource

sourcefiles = $(shell test -d ${srcdir}/proto && find ${srcdir}/proto -type f | grep -v CVS | grep -v "~")

included: ${sourcefiles} ${top_srcdir}/batch/make/sortresources.py ${top_srcdir}/batch/make/sortresources Makefile
	@sh ${top_srcdir}/batch/make/sortresources ${srcdir}/proto $@ ${top_srcdir}/batch/make/sortresources.py || { rm -rf $@; false; }

all: included

linked_included.%: included
	if test ! -r $@; then \
		if test -d included; then\
			ln -sf ./included $@;\
		else\
			ln -sf ${srcdir}/included $@;\
		fi;\
	fi

install-data-local: linked_included.install
#   copy processed included resources into target directory
	mkdir -p ${DESTDIR}${resourcedir}/included
	cp -r $</* ${DESTDIR}${resourcedir}/included
	find ${DESTDIR}${resourcedir} -type d -exec chmod 755 \{\} \;
	find ${DESTDIR}${resourcedir} -type f -exec chmod 644 \{\} \;
	rm -f $<	

uninstall-local:
#   remove resources
	rm -rf ${DESTDIR}${resourcedir}/included

dist-hook: linked_included.dist
#   copy processed included resources into distribution
	mkdir -p $(distdir)/included
	cp -r $</* $(distdir)/included/

#	delete temporary files
	rm -f $< $(distdir)/included/map.dtd

#	update included resources to correct map version
	if test -r included/.mapversion; then \
		for file in `find $(distdir)/included/ -name "*.aamap.xml"`; do \
			echo "Adapting dtd in $$file" | sed -e "s,$(distdir)/included/,,";\
			sed -e "s,map.dtd,AATeam/map-`cat included/.mapversion`.dtd,g" < $$file > $$file.processed ;\
			mv $$file.processed $$file ;\
		done ;\
	fi

clean-local:
	test -d ${srcdir}/proto && rm -rf included || true
