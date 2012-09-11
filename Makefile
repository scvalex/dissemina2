.PHONY: all build dist install test clean doc p bench

all: build

build: dist/setup-config
	cabal build

dist: test
	cabal sdist

install: build
	cabal install

test: build
	cabal test

clean:
	cabal clean

dist/setup-config: dissemina2.cabal
	cabal configure

doc: build
	cabal haddock

p: clean
	permamake.sh $(shell find . -name '*.hs') *.cabal Makefile *.md

bench: build
	dist/build/dissemina2-sendfile/dissemina2-sendfile &
	ab -n 10000 -c 10 "http://localhost:5000/Makefile"
