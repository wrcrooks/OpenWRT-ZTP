PROG=ztp

OPTFLAGS=@OPTFLAGS@
CC=@CC@
CFLAGS=@CFLAGS@ ${OPTFLAGS}
LIBS=@LIBS@
LDFLAGS=@LDFLAGS@

prefix=@prefix@
exec_prefix=@exec_prefix@
bindir=@bindir@
datarootdir=@datarootdir@
datadir=@datadir@
mandir=@mandir@

SRCS=$(PROG).sh

OBJS=$(PROG).o

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) ${LIBS}

clean:
	rm -f $(PROG) $(OBJS) $(PROG).core $(PROG).sh~

distclean: clean
	rm -f Makefile

shc:
	DATE=`date +%Y%m%d` && \
	mkdir $(PROG)-$$DATE && \
	cp -p LICENSE CHANGES $(SRCS) $(PROG).8 $(PROG)-$$DATE && \
	cp -p Makefile.in $(PROG)-$$DATE && \
	perl -pi -e "s/\@VERSION\@/$$DATE/" ztp.sh && \
	shc -f ztp.sh $(PROG)-$$DATE/ztp
# rm -rf $(PROG)-$$DATE && \

install: $(PROG)
	install -m 755 $(PROG) ${DESTDIR}${bindir}
	mkdir -p ${DESTDIR}${mandir}/man8
	install -m 644 $(PROG).8 ${DESTDIR}${mandir}/man8

uninstall:
	rm -f ${DESTDIR}${bindir}/$(PROG)
	rm -f ${DESTDIR}${mandir}/man8/$(PROG).8