# TODO: shoube be versioning ...
VERSION=0.0.1
LUADIR=deps/luajit
LUAJIT_VERSION=$(shell git --git-dir ${LUADIR}/.git describe --tags)
YAJLDIR=deps/yajl
YAJL_VERSION=$(shell git --git-dir ${YAJLDIR}/.git describe --tags)
UVDIR=deps/uv
UV_VERSION=$(shell git --git-dir ${UVDIR}/.git describe --all --long | cut -f 3 -d -)
HTTPDIR=deps/http-parser
HTTP_VERSION=$(shell git --git-dir ${HTTPDIR}/.git describe --tags)

PREFIX?=/usr/local
BINDIR?=${DESTDIR}${PREFIX}/bin
INCDIR?=${DESTDIR}${PREFIX}/include/lev
LIBDIR?=${DESTDIR}${PREFIX}/lib/lev

BUILDTYPE?=Debug

all:
	tools/build.py build

out/Makefile: common.gypi deps/luajit.gyp deps/uv/uv.gyp deps/zlib/zlib.gyp deps/openssl.gyp deps/luacrypto.gyp deps/yajl.gyp deps/http-parser/http_parser.gyp lev.gyp
	tools/gyp_lev -f make

clean:
	-rm -rf out/Makefile
	-rm -rf out/**/lev

test: test-lua

test-all: test-lua test-install test-uninstall

DESTDIR=test_install

test-lua: out/${BUILDTYPE}/lev
	tools/build.py test

test-install: install
	test -f ${BINDIR}/lev
	test -d ${INCDIR}
	test -d ${LIBDIR}

test-uninstall: uninstall
	test ! -f ${BINDIR}/lev
	test ! -d ${INCDIR}
	test ! -d ${LIBDIR}

install: all
	mkdir -p ${BINDIR}
	install out/${BUILDTYPE}/lev ${BINDIR}/lev
	mkdir -p ${LIBDIR}
	cp lib/lev/*.lua ${LIBDIR}
	mkdir -p ${INCDIR}/luajit
	cp ${LUADIR}/src/lua.h ${INCDIR}/luajit/
	cp ${LUADIR}/src/lauxlib.h ${INCDIR}/luajit/
	cp ${LUADIR}/src/luaconf.h ${INCDIR}/luajit/
	cp ${LUADIR}/src/luajit.h ${INCDIR}/luajit/
	cp ${LUADIR}/src/lualib.h ${INCDIR}/luajit/
	mkdir -p ${INCDIR}/http_parser
	cp ${HTTPDIR}/http_parser.h ${INCDIR}/http_parser/
	mkdir -p ${INCDIR}/uv
	cp -r ${UVDIR}/include/* ${INCDIR}/uv/
	cp src/*.h ${INCDIR}/

uninstall:
	test -f ${BINDIR}/lev && rm -f ${BINDIR}/lev
	test -d ${LIBDIR} && rm -rf ${LIBDIR}
	test -d ${INCDIR} && rm -rf ${INCDIR}

api: api.markdown

api.markdown: $(wildcard lib/*.lua)
	find lib -name "*.lua" | grep -v "lev.lua" | sort | xargs -l lev tools/doc-parser.lua > $@

DIST_DIR?=./dist
DIST_NAME=lev-${VERSION}
DIST_FOLDER=${DIST_DIR}/${VERSION}/${DIST_NAME}
DIST_FILE=${DIST_FOLDER}.tar.gz
dist-build:
	sed -e 's/^VERSION=.*/VERSION=${VERSION}/' \
            -e 's/^LUAJIT_VERSION=.*/LUAJIT_VERSION=${LUAJIT_VERSION}/' \
            -e 's/^UV_VERSION=.*/UV_VERSION=${UV_VERSION}/' \
            -e 's/^HTTP_VERSION=.*/HTTP_VERSION=${HTTP_VERSION}/' \
            -e 's/^YAJL_VERSION=.*/YAJL_VERSION=${YAJL_VERSION}/' < Makefile > Makefile.dist
	sed -e 's/LEV_VERSION=".*/LEV_VERSION=\"${VERSION}\"'\'',/' \
            -e 's/LUAJIT_VERSION=".*/LUAJIT_VERSION=\"${LUAJIT_VERSION}\"'\'',/' \
            -e 's/UV_VERSION=".*/UV_VERSION=\"${UV_VERSION}\"'\'',/' \
            -e 's/HTTP_VERSION=".*/HTTP_VERSION=\"${HTTP_VERSION}\"'\'',/' \
            -e 's/YAJL_VERSIONISH=".*/YAJL_VERSIONISH=\"${YAJL_VERSION}\"'\'',/' < lev.gyp > lev.gyp.dist

tarball: dist-build
	rm -rf ${DIST_FOLDER} ${DIST_FILE}
	mkdir -p ${DIST_DIR}
	git clone . ${DIST_FOLDER}
	cp deps/gitmodules.local ${DIST_FOLDER}/.gitmodules
	cd ${DIST_FOLDER} ; git submodule update --init
	find ${DIST_FOLDER} -name ".git*" | xargs rm -r
	mv Makefile.dist ${DIST_FOLDER}/Makefile
	mv lev.gyp.dist ${DIST_FOLDER}/lev.gyp
	tar -czf ${DIST_FILE} -C ${DIST_DIR}/${VERSION} ${DIST_NAME}
	rm -rf ${DIST_FOLDER}

.PHONY: test test-lua test-all test-install test-uninstall install uninstall all api.markdown tarball dist

