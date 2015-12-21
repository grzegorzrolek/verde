# Makefile for Verde the logotype project directory
# Copyright 2015 Grzegorz Rolek
# Subject to the BSD 3-Clause License


build/Verde.otf: font.pfa | build
	makeotf -f $< -o $@

build:
	mkdir $@

lint: font.pfa
	t1lint $<

cleanall: clean
	rm -rf build

clean:
	rm -f font.pfa current.fpr


# Following rules can be destructive. Conditionals help prevent loss of any
# file changes that appear to be newer. See README for details.

PFADIFF=diff -q <(t1disasm font.pfa) font.ps >/dev/null
SHELL=/bin/bash # for process substitution on diff

ifeq ($(shell test font.pfa -nt font.ps && ! $(PFADIFF); echo $$?),0)

# Binary is being modified, apparently; can disassemble

font.pfa:
	@echo # dummy; prints 'up to date'

font.ps: %.ps: %.pfa
	t1disasm $< $@

else ifeq ($(shell test -f font.pfa && ! $(PFADIFF); echo $$?),0)

# Source 'out of sync'; either source or binary could lose its changes

ERRMSG="error: font.ps has changed since last disassembly"

font.pfa: .FORCE
	@echo $(ERRMSG)"; changes made on font.pfa could be lost"
	@echo "run \`t1asm -a font.ps $@\` manually to proceed"
	@exit 1

font.ps: .FORCE
	@echo $(ERRMSG)"; these changes could be lost"
	@echo "run \`t1disasm font.pfa $@\` manually to proceed"
	@exit 1

else

# Binary either non-existent or does not differ; can assemble

font.pfa: %.pfa: %.ps
	t1asm -a $< $@

font.ps:
	@echo # dummy

endif

.FORCE:

