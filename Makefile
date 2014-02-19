VERSION=20140219-2
DIST=simgal-$(VERSION)
RM=/bin/rm

DISTFILES=LICENSE Makefile README simgal

$(DIST).tar.bz2:
	mkdir $(DIST)
	cp $(DISTFILES) $(DIST)/
	tar cf $(DIST).tar --exclude .git $(DIST)
	bzip2 -9 $(DIST).tar
	$(RM) -rf $(DIST)

dist: $(DIST).tar.bz2
