#!/bin/bash

releasever="${BASH_SOURCE:9:1}"
baseurl="https://cdn.redhat.com/content/dist/rhel${releasever}/${releasever}/x86_64"

for REPO in baseos appstream ; do
	reposync --repo=rhel-${releasever}-for-x86_64-${REPO}-rpms -b -n -u > ${REPO}-bin
	sed -i "s?${baseurl}/${REPO}/os/Packages/??g" ${REPO}-bin

	reposync --repo=rhel-${releasever}-for-x86_64-${REPO}-source-rpms -b -n -u > ${REPO}-source
	sed -i "s?${baseurl}/${REPO}/source/SRPMS/Packages/??g" ${REPO}-source
done

REPO="codeready-builder"

reposync --repo=${REPO}-for-rhel-${releasever}-x86_64-rpms -b -n -u > ${REPO}-bin
sed -i "s?${baseurl}/${REPO}/os/Packages/??g" ${REPO}-bin

reposync --repo=${REPO}-for-rhel-${releasever}-x86_64-source-rpms -b -n -u > ${REPO}-source
sed -i "s?${baseurl}/${REPO}/source/SRPMS/Packages/??g" ${REPO}-source
