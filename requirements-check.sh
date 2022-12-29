#!/bin/env bash
# RUN ME $> bash <(curl -sL <<URL>> ) > report.txt

export LANG=en
echo "Checking basic requirements"
builtin type -P awk || echo "We need awk command installed and in the user PATH"
builtin type -P curl || echo "We need curl command installed and in the user PATH" 
builtin type -P docker || echo "We need docker installed and in the user PATH"
builtin type -P free  || echo "We need free command installed and in the user PATH"
builtin type -P kubectl || echo "We need kubectl installed and in the user PATH"
builtin type -P lscpu || echo "We need lscpu command installed and in the user PATH"

echo "Checking hardware specs"
lscpu | awk -F: '/^CPU max MHz:/ { mhz=$2 } /^CPU\(s\):/{cores=$2} END { if (cores -2 < 0) print "Not enough cores. At least 2 cores needed. \n"; else printf "Enought cores: %i - OK. \n", cores; if (mhz - 1999 <1) printf "Not enough clock. Minimum required is 2000, measured: %d \n", mhz; else printf "Enough clock speed: %d Mhz - OK. \n", mhz } '

free --giga | awk -F' ' '/^Mem:/ {total=$2} END { if (total -15 <1) printf "Not enough total memory. 16GB is the minimun requirement. Memory found: %d", total; else printf "Total memory: %s - OK. \n", total ; exit total < 16}'

echo "Network access"
curl -s -v -o /dev/null https://ec2.amazonaws.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*Server key exchange.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} END { if (3 == certificate + verify + finished ) { printf "https://ec2.amazonaws.com safely reachable - OK. \n"; } else printf "https://ec2.amazonaws.com safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://k8s.kurl.sh 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*Server key exchange.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} END { if (3 == certificate + verify + finished ) { printf "https://k8s.kurl.sh safely reachable - OK. \n"; } else printf "https://k8s.kurl.sh safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://proxy.replicated.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://proxy.replicated.com safely reachable - OK. \n"; } else printf "https://proxy.replicated.com safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://replicated.app 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://replicated.app safely reachable - OK. \n"; } else printf "https://replicated.app safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://kots.io 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://kots.io safely reachable - OK. \n"; } else printf "https://kots.io safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://github.com 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://github.com safely reachable - OK. \n"; } else printf "https://github.com safely unreachable - FAIL.\n"; }'

curl -s -v -o /dev/null https://k8s.gcr.io 2>&1 | awk -F' ' '/\* TLSv.*TLS handshake.*Certificate.*/ {certificate=1} /\* TLSv.*TLS handshake.*CERT verify.*/ {verify=1} /\* TLSv.*TLS handshake.*Finished.*/ {finished=1} /\* TLSv.*TLS handshake.*Newsession.*/ {session=1} END { if (4 == certificate + verify + finished + session) { printf "https://k8s.gcr.io safely reachable - OK. \n"; } else printf "https://k8s.gcr.io safely unreachable - FAIL.\n"; }'
