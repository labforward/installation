#!/bin/env bash
# RUN ME $> bash <(curl -sL <<URL>> ) > report.txt

FAIL=0
export LANG=en
echo "Checking basic requirements"
TESTS=$(builtin type -P awk > /dev/null || echo "We need awk command installed and in the user PATH. FAIL."; \
builtin type -P curl > /dev/null || echo "We need curl command installed and in the user PATH. FAIL."; \
builtin type -P docker > /dev/null || echo "We need docker installed and in the user PATH. FAIL."; \
builtin type -P free  > /dev/null || echo "We need free command installed and in the user PATH. FAIL."; \
builtin type -P kubectl > /dev/null || echo "We need kubectl installed and in the user PATH. FAIL."; \
builtin type -P lscpu > /dev/null || echo "We need lscpu command installed and in the user PATH. FAIL." )

echo $TESTS
if [[ "$TESTS" == *"FAIL"* ]]; then
	FAIL=1
else
	echo "basic commands found. OK"
fi

echo "Checking hardware specs"
TEST_CPU=$(lscpu | awk -F: '/^CPU max MHz:/ { mhz=$2 } /^CPU\(s\):/{cores=$2} END { if (cores -2 < 0) print "Not enough cores. At least 2 cores needed. \n"; else printf "Enought cores: %i - OK. \n", cores; if (mhz - 1999 <1) printf "Not enough clock. Minimum required is 2000, measured: %d \n", mhz; else printf "Enough clock speed: %d Mhz - OK. \n", mhz } ')
echo $TEST_CPU
if [[ "$TEST_CPU" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_MEM=$(free --giga | awk -F' ' '/^Mem:/ {total=$2} END { if (total < 16) printf "Not enough total memory. 16GB is the minimun requirement. Memory found: %d FAIL.\n", total; else printf "Total memory: %s - OK. \n", total ; exit total < 16}')
echo $TEST_MEM
if [[ "$TEST_MEM" == *"FAIL." ]]; then
	FAIL=1
fi

echo "Network access"
TEST_EC2=$(curl -s -v -o /dev/null https://ec2.amazonaws.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*Server key exchange.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} END { if (3 == certificate + verify + finished ) { printf "https://ec2.amazonaws.com safely reachable - OK. \n"; } else printf "https://ec2.amazonaws.com safely unreachable - FAIL.\n"; }')
echo $TEST_EC2
if [[ "$TEST_EC2" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_KURL=$(curl -s -v -o /dev/null https://k8s.kurl.sh 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*Server key exchange.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} END { if (3 == certificate + verify + finished ) { printf "https://k8s.kurl.sh safely reachable - OK. \n"; } else printf "https://k8s.kurl.sh safely unreachable - FAIL.\n"; }')
echo $TEST_KURL
if [[ "$TEST_KURL" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_REPLICATED_PROXY=$(curl -s -v -o /dev/null https://proxy.replicated.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://proxy.replicated.com safely reachable - OK. \n"; } else printf "https://proxy.replicated.com safely unreachable - FAIL.\n"; }')
echo $TEST_REPLICATED_PROXY
if [[ "$TEST_REPLICATED_PROXY" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_REPLICATED=$(curl -s -v -o /dev/null https://replicated.app 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://replicated.app safely reachable - OK. \n"; } else printf "https://replicated.app safely unreachable - FAIL.\n"; }')
echo $TEST_REPLICATED
if [[ "$TEST_REPLICATED" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_KOTS=$(curl -s -v -o /dev/null https://kots.io 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://kots.io safely reachable - OK. \n"; } else printf "https://kots.io safely unreachable - FAIL.\n"; }')
echo $TEST_KOTS
if [[ "$TEST_KOTS" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_GITHUB=$(curl -s -v -o /dev/null https://github.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://github.com safely reachable - OK. \n"; } else printf "https://github.com safely unreachable - FAIL.\n"; }')
echo $TEST_GITHUB
if [[ "$TEST_GITHUB" == *"FAIL." ]]; then
	FAIL=1
fi

TEST_K8S_GCR=$(curl -s -v -o /dev/null https://k8s.gcr.io 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://k8s.gcr.io safely reachable - OK. \n"; } else printf "https://k8s.gcr.io safely unreachable - FAIL.\n"; }')
echo $TEST_K8S_GCR
if [[ "TEST_K8S_GCR" == *"FAIL." ]]; then
	FAIL=1
fi

if test $FAIL -ne 0 
then
	echo "One or more requirements test has failed !";
	echo "You need to fix this problems and run this script again ";
else
	echo "This system has the minimal requirements for installation ";
fi
