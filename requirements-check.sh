#!/bin/env bash
# RUN ME $> bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh ) > report.txt
# RUN ME in docker image $> docker run -it <IMAGE_NAME>:<TAG> bash -c "bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )"

FAIL=0
export LANG=en

function validate() {
	str_to_validate=$1
	hide="${2:-no}"
	bullet="${3}"
	if [[ "$hide" == "no" ]]; then
		echo "$bullet$str_to_validate"
	fi
	if [[ "$str_to_validate" == *"FAILED." ]]; then
		FAIL=1
	fi
}

function check_memory_gigabytes() {
	minimum=${1:-4}
	builtin type -P free  > /dev/null || validate "We need the command 'free' installed and in the user PATH, FAILED."; \
	TEST_MEM=$(builtin type -P free  > /dev/null && (free --giga && echo "Minimum: $minimum") | awk -F' ' '/^Mem:/ {total=$2}; /^Minimum:/ {minimumGB=$2};  END { if (total < minimumGB) printf "Not enough total memory. %d GB is the minimum requirement. Memory found: %d FAILED.\n", minimumGB, total; else printf "Total memory: %s - OK. \n", total ; exit total < minimumGB}')
	validate "$TEST_MEM"
}

function curl_request() {
	URL=$1
	
	response=$(curl -s -v -o /dev/null $URL 2>&1 | awk "/HTTP\/.+ (2[0-9][0-9]|3[0-9][0-9]).*/ {success=1} END { if (1 == success) { printf \"$URL safely reachable - OK. \n\"; } else printf \"$URL safely unreachable - FAILED.\n\"; }")
	validate "$response" "no" "  > "
}

function check_domain_resolution() {
    local domain="$1"
    ips=$(dig "$domain" +short | wc -l)
    if [[ "$ips" == "0" ]]; then
        validate "  > DNS $domain FAILED."
	else 
		echo "  > DNS $domain OK."
    fi
}

function check_resolv_conf() {
	search=($(grep -E '^search' /etc/resolv.conf | awk '{print NF - 1}'))
	if (( search > 3 )); then
		validate "  > resolv.conf has too many search domains FAILED."
	else
		echo "  > resolv.conf has $search search domain names. This is OK."
	fi
}

echo "In which domain Labforward applications are beeing installed ?" 
read -e domain

echo "Are you going to install LabFolder ? [yes/No]"
read -e labfolder_enabled

echo "Are you going to install LabOperator ? [yes/No]"
read -e laboperator_enabled

echo "Start copying from here"
echo "Testing domains"
check_resolv_conf
check_domain_resolution "account.$domain"
check_domain_resolution "admin-console.$domain"
if [[ "yes" == "$labfolder_enabled" ]]; then
	check_domain_resolution "labfolder.$domain"
fi
if [[ "yes" == "$laboperator_enabled" ]]; then
	check_domain_resolution "laboperator.$domain"
	check_domain_resolution "connector-manager.$domain"
	check_domain_resolution "workflow-editor.$domain"
fi
check_domain_resolution "labregister.$domain"
check_domain_resolution "fos.$domain"

TESTS=$(builtin type -P awk > /dev/null || echo "We need awk command installed and in the user PATH. FAILED."; \
builtin type -P curl > /dev/null || echo "We need curl command installed and in the user PATH.\n  > command curl not found FAILED."; \
builtin type -P lscpu > /dev/null || echo "We need lscpu command installed and in the user PATH. FAILED." )

validate "$TESTS"

# 150GB = 157286400 kilobytes
TEST_AVAILABLE_SPACE=$(df -Pk /var /var/lib /var/lib/kubelet 2> /dev/null | tail -1 | awk -F ' ' 'BEGIN{kilobytes=0}{ if ($4+0>kilobytes) kilobytes=$4+0; source=$6;} END {if (kilobytes 157286400 < 1) printf "Not enough disk space. There`s only %d (kilobytes) available. The installation requires at least 150 GB of diskspace. FAILED.", kilobytes; else printf "Mountpoint \"%s\" has enought disk space - OK.", source}')
validate "$TEST_AVAILABLE_SPACE"

echo "Checking hardware specs"
TEST_CPU_CORES=$(lscpu 2>/dev/null| awk -F: 'IGNORECASE = 1;/^CPU\(s\):/{vcores=$2; minimumVCores=4} END { if (vcores < minimumVCores) printf "Not enough vcores. At least %d vcores needed. Found only %d \n", minimumVCores, vcores; else printf "Enought vcores: %i - OK. \n", vcores; } ' | grep -i cores)
validate "$TEST_CPU_CORES" "hide"

TEST_CPU_CLOCK=$(lscpu 2>/dev/null| awk -F: 'IGNORECASE = 1;/MHz:/ { mhz=$2 } IGNORECASE = 1;/max MHz:/ {max=$2 } END { if (max > mhz) mhz = max; if (mhz < 2600) printf "Not enough clock. Minimum required is 2600, measured: %d Mhz\n", mhz; else printf "Enough clock speed: %d Mhz - OK. \n", mhz } ' | grep -i Mhz)
validate "$TEST_CPU_CLOCK" "hide"

check_memory_gigabytes 100

echo "Network access"

curl_request 'https://ec2.amazonaws.com'
curl_request 'https://k8s.kurl.sh'
curl_request 'https://replicated.app'
curl_request 'https://kots.io'
curl_request 'https://github.com'
curl_request 'https://k8s.gcr.io'

echo "These are the contents of /etc/*release:" && cat /etc/*release | grep -i name | grep -v -i "CODE" | grep -v -i "_NAME"

if test $FAIL -ne 0 
then
	echo "***********************************************************************";
	echo "One or more requirement tests failed !";
	echo "You need to fix these problems before proceeding with the installation. ";
	echo "Run this script as many times as required."
	echo "Fixing these items above is required for the installation appointment."
	echo "If you have any questions get in touch with Labforward support."
	echo "***********************************************************************";
else
	echo "***********************************************************************";
	echo "This system has the minimal requirements for installation ";
	echo "Laboperator: $laboperator_enabled ";
	echo "Labfolder: $labfolder_enabled ";
	echo "Domain tested: $domain ";
	echo "***********************************************************************";
	echo "If you want support with the installation next steps, schedule an installation meeting and paste the output about, in between star lines, in the 'Result of the requirement-check script' field."; 
	echo "Installation meeting calendar: https://calendar.app.google/do5gQLwfkJbTVD5A7 ";
fi

