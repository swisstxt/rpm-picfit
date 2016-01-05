HOME=$(shell pwd)
VERSION="1"
RELEASE=$(shell /opt/buildhelper/buildhelper getgitrev .)
NAME=picfit
SPEC=$(shell /opt/buildhelper/buildhelper getspec ${NAME})
ARCH=$(shell /opt/buildhelper/buildhelper getarch)
OS_RELEASE=$(shell /opt/buildhelper/buildhelper getosrelease)
GOPATH=${HOME}/SOURCES/

all: build

clean:
	rm -rf ./rpmbuild
	rm -rf ./SOURCES/src ./SOURCES/bin ./SOURCES/lib
	rm -rf ./SOURCES/picfit.bin
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/
	mkdir -p ./SPECS ./SOURCES/src ./SOURCES/bin ./SOURCES/lib


get-thirdparty:
	echo ${GOPATH}
	go get https://github.com/thoas/picfit

tidy-thirdparty:
	rm -rf ./SOURCES/src ./SOURCES/bin ./SOURCES/lib

build-thirdparty: get-thirdparty
	cd ./SOURCES/src/github.com/thoas/picfit; make build
	cp ./SOURCES/src/github.com/thoas/picfit/bin/picfit ./SOURCES/picfit.bin

build: clean build-thirdparty tidy-thirdparty
	cp -r ./SPECS/* ./rpmbuild/SPECS/ || true
	cp -r ./SOURCES/* ./rpmbuild/SOURCES/ || true
	rpmbuild -ba ${SPEC} \
	--define "ver ${VERSION}" \
	--define "rel ${RELEASE}" \
	--define "name ${NAME}" \
	--define "os_rel ${OS_RELEASE}" \
	--define "arch ${ARCH}" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \

publish:
	/opt/buildhelper/buildhelper pushrpm yum-01.stxt.media.int:8080/swisstxt-centos
