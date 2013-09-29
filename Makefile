# Makefile for ECOS
# Configuration of make process in ecos.mk

include ecos.mk
C = $(CC) $(CFLAGS) -Iinclude -Iexternal/ldl/include -Iexternal/amd/include -Iexternal/SuiteSparse_config

# Compile all C code, including the C-callable routine
all: demo	

# build Tim Davis' sparse LDL package
ldl: ldll.o
	
ldll.o: 
	( cd external/ldl    ; $(MAKE) )
	$(AR) -x external/ldl/libldl.a ldll.o
	
# build Tim Davis' AMD package
AMD = amd_aat amd_1 amd_2 amd_dump amd_postorder amd_post_tree amd_defaults \
    amd_order amd_control amd_info amd_valid amd_preprocess
AMDL = $(addsuffix .o, $(subst amd_,amd_l_,$(AMD)))
amd_global.o $(AMDL):
	( cd external/amd    ; $(MAKE) )
	$(AR) -x external/amd/libamd.a amd_global.o $(AMDL)

# build ECOS
ecos: libecos.a
	
libecos.a: ecos.o kkt.o cone.o spla.o timer.o preproc.o splamm.o ldll.o amd_global.o $(AMDL)
	$(ARCHIVE) libecos.a *.o
	- $(RANLIB) libecos.a

ecos.o: src/ecos.c include/ecos.h
	$(C) -c src/ecos.c -o ecos.o

kkt.o: src/kkt.c include/kkt.h
	$(C) -c src/kkt.c -o kkt.o

cone.o: src/cone.c include/cone.h
	$(C) -c src/cone.c -o cone.o

preproc.o: src/preproc.c
	$(C) -c src/preproc.c -o preproc.o

spla.o: src/spla.c include/spla.h
	$(C) -c src/spla.c -o spla.o

splamm.o: src/splamm.c include/splamm.h
	$(C) -c src/splamm.c -o splamm.o

timer.o: src/timer.c include/timer.h
	$(C) -c src/timer.c -o timer.o

# ECOS demo
demo: runecos
	
runecos: libecos.a src/runecos.c 
	$(C) -o runecos src/runecos.c libecos.a $(LIBS)
	echo ECOS successfully built. Type ./runecos to run demo problem.
	

# remove object files, but keep the compiled programs and library archives
clean:
	( cd external/ldl    ; $(MAKE) clean )
	( cd external/amd    ; $(MAKE) clean )
	- $(RM) $(CLEAN)

# clean, and then remove compiled programs and library archives
purge: clean
	( cd external/ldl    ; $(MAKE) purge )
	( cd external/amd    ; $(MAKE) purge )	
	- $(RM) libecos.a runecos

