INSTALL_ROOT?=
INSTALL_PREFIX?=/usr/local

INSTALL_PATH?=${INSTALL_ROOT}${INSTALL_PREFIX}

install:
	install -m 755 amal.rb ${INSTALL_PATH}/bin/amal.rb

uninstall:
	rm -f ${INSTALL_PATH}/bin/amal.rb
