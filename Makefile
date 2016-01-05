HOME=$(shell pwd)
VERSION="1"
RELEASE=$(shell /opt/buildhelper/buildhelper getgitrev .)
NAME=picfit
SPEC=$(shell /opt/buildhelper/buildhelper getspec ${NAME})
ARCH=$(shell /opt/buildhelper/buildhelper getarch)
OS_RELEASE=$(shell /opt/buildhelper/buildhelper getosrelease)
export GOPATH=${HOME}/SOURCES/
export PATH :=${GOPATH}/bin/:$(PATH)

all: build

clean:
	rm -rf ./rpmbuild
	rm -rf ./SOURCES/src ./SOURCES/bin ./SOURCES/lib
	rm -rf ./SOURCES/picfit.bin
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/
	mkdir -p ./SPECS ./SOURCES/src ./SOURCES/bin ./SOURCES/pkg
	go get github.com/tools/godep golang.org/x/image/bmp github.com/stretchr/testify

get-thirdparty:
	echo ${GOPATH}
	git clone https://github.com/thoas/picfit ./SOURCES/src/github.com/thoas/picfit

tidy-thirdparty:
	rm -rf ./SOURCES/src ./SOURCES/bin ./SOURCES/pkg

build-thirdparty: get-thirdparty
	cd ./SOURCES/src/github.com/thoas/picfit; godep restore; godep go install
	cp ./SOURCES/bin/picfit ./SOURCES/picfit.bin

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
