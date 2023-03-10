#!/bin/env bash
# RUN ME $> bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh ) > report.txt
# RUN ME in docker image $> docker run -it <IMAGE_NAME>:<TAG> bash -c "bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )"

FAIL=0
export LANG=en

function validate() {
	str_to_validate=$1
	echo "$str_to_validate"
	if [[ "$str_to_validate" == *"FAIL." ]]; then
		FAIL=1
	fi
}
function curl_request() {
	URL=$1
	
	response=$(curl -s -v -o /dev/null $URL 2>&1 | awk "/HTTP\/.+ (2[0-9][0-9]|3[0-9][0-9]).*/ {success=1} END { if (1 == success) { printf \"$URL safely reachable - OK. \n\"; } else printf \"$URL safely unreachable - FAIL.\n\"; }")
	validate "$response"
}

echo "Checking basic requirements"
TESTS=$(builtin type -P awk > /dev/null || echo "We need awk command installed and in the user PATH. FAIL."; \
builtin type -P curl > /dev/null || echo "We need curl command installed and in the user PATH. FAIL."; \
builtin type -P free  > /dev/null || echo "We need free command installed and in the user PATH. FAIL."; \
builtin type -P lscpu > /dev/null || echo "We need lscpu command installed and in the user PATH. FAIL." )

validate "$TESTS"

# 150GB = 157286400 kilobytes
TEST_AVAILABLE_SPACE=$(df -Pk /var /var/lib /var/lib/kubelet 2> /dev/null | tail -1 | awk -F ' ' 'BEGIN{kilobytes=0}{ if ($4+0>kilobytes) kilobytes=$4+0; source=$6;} END {if (kilobytes 157286400 < 1) printf "Not enough disk space. There`s only %d (kilobytes) available. The installation requires at least 150 GB of diskspace. FAIL.", kilobytes; else printf "%s has enought disk space.", source}')
validate "$TEST_AVAILABLE_SPACE"

echo "Checking hardware specs"
TEST_CPU_CORES=$(lscpu 2>/dev/null| awk -F: 'IGNORECASE = 1;/^CPU\(s\):/{cores=$2} END { if (cores -2 < 0) print "Not enough cores. At least 2 cores needed. \n"; else printf "Enought cores: %i - OK. \n", cores; } ' | grep -i cores)
validate "$TEST_CPU_CORES"

TEST_CPU_CLOCK=$(lscpu 2>/dev/null| awk -F: 'IGNORECASE = 1;/MHz:/ { mhz=$2 } IGNORECASE = 1;/max MHz:/ {max=$2 } END { if (max > mhz) mhz = max; if (mhz < 2600) printf "Not enough clock. Minimum required is 2600, measured: %d Mhz\n", mhz; else printf "Enough clock speed: %d Mhz - OK. \n", mhz } ' | grep -i Mhz)
validate "$TEST_CPU_CLOCK"

TEST_MEM=$(free --giga | awk -F' ' '/^Mem:/ {total=$2} END { if (total < 16) printf "Not enough total memory. 16GB is the minimun requirement. Memory found: %d FAIL.\n", total; else printf "Total memory: %s - OK. \n", total ; exit total < 16}')
validate "$TEST_MEM"


echo "Network access"

curl_request 'https://ec2.amazonaws.com'
curl_request 'https://k8s.kurl.sh'
curl_request 'https://replicated.app'
curl_request 'https://kots.io'
curl_request 'https://github.com'
curl_request 'https://k8s.gcr.io'

echo "df -h"
df -h

[ -e /proc/version ] && echo "These are the contents of /proc/version:" && cat /proc/version
[ -f /etc/os-release ] && echo "These are the contents of /etc/os-release:" && cat /etc/os-release
[ -f /etc/issue ] && echo "These are the contents of /etc/issue:" && cat /etc/issue
echo "These are the contents of /etc/*release:" && cat /etc/*release

if test $FAIL -ne 0 
then
	echo "One or more requirement tests failed !";
	echo "You need to fix this problems and run this script again ";
else
	echo "This system has the minimal requirements for installation ";
fi

