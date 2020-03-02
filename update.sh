#!/usr/bin/env bash
set -e
set -Euo pipefail
set -x
trap 'rm -rf ${TEMP_DIR}' EXIT

TEMP_DIR=$(mktemp -d)
CHECKSUM_DIR=$(readlink -f ./checksums)
METADATA_DIR=$(readlink -f ./metadata)

function ensure_directory {
	if [ ! -d "${1}" ]
	then
		mkdir -p "${1}"
	fi
}

function get_extensions {
	case "${1}" in
	"linux") echo 'tar.gz'
		;;
	"macosx") echo 'tar.gz' 'pkg'
		;;
	"windows") echo 'zip' 'msi'
		;;
	esac
}

function get_archs {
	case "${1}" in
	"linux") echo 'x64' 'aarch64'
		;;
	"macosx") echo 'x64'
		;;
	"windows") echo 'x64'
		;;
	esac
}

function archive_filename {
	local version="${1}"
	local os="${2}"
	local arch="${3}"
	local ext="${4}"
	echo -n "amazon-corretto-${version}-${os}-${arch}.${ext}"
}

function download {
	local version="${1}"
	local os="${2}"
	local arch="${3}"
	local ext="${4}"
	local filename="$(archive_filename "${version}" "${os}" "${arch}" "${ext}")"
	local url="https://d3pxv6yz143wms.cloudfront.net/${version}/${filename}"
	local metadata_file="${METADATA_DIR}/${filename}.json"
	local archive="${TEMP_DIR}/${filename}"
	if [[ -f "${metadata_file}" ]]
	then
		echo "Skipping ${filename}"
	else
		curl --silent --show-error --fail -w "%{filename_effective}\n" --output "${archive}" "${url}" || return 1
		local MD5=$(md5sum "${archive}" | cut -f 1 -d ' ')
		echo "${MD5}  ${filename}" > "${CHECKSUM_DIR}/${filename}.md5"
		local SHA1=$(sha1sum "${archive}"| cut -f 1 -d ' ') 
		echo "${SHA1}  ${filename}" > "${CHECKSUM_DIR}/${filename}.sha1"
		local SHA256=$(sha256sum "${archive}" | cut -f 1 -d ' ')
		echo "${SHA256}  ${filename}" > "${CHECKSUM_DIR}/${filename}.sha256"
		local SHA512=$(sha512sum "${archive}" | cut -f 1 -d ' ')
		echo "${SHA512}  ${filename}" > "${CHECKSUM_DIR}/${filename}.sha512"

		local json="{
  \"filename\": \"${filename}\",
  \"url\": \"${url}\",
  \"md5\": \"${MD5}\",
  \"md5_file\": \"${filename}.md5\",
  \"sha1\": \"${SHA1}\",
  \"sha1_file\": \"${filename}.sha1\",
  \"sha256\": \"${SHA256}\",
  \"sha256_file\": \"${filename}.sha256\",
  \"sha512\": \"${SHA512}\",
  \"sha512_file\": \"${filename}.sha512\",
  \"version\": \"${version}\",
  \"os\": \"${os}\",
  \"arch\": \"${arch}\",
  \"archive_type\": \"${ext}\"
}"
		echo "${json}" > "${metadata_file}"
		rm -f "${archive}"
	fi
}

ensure_directory "${CHECKSUM_DIR}"
ensure_directory "${METADATA_DIR}"

CURL_ARGS=('--silent' '--show-error' '--fail' '--output' "${TEMP_DIR}/releases-#1.json")
if [[ -n "${GITHUB_API_TOKEN:-}" ]]; then
	CURL_ARGS+=('-H' "Authorization: token ${GITHUB_API_TOKEN}")
fi

curl "${CURL_ARGS[@]}" 'https://api.github.com/repos/corretto/{corretto-8}/releases'
curl "${CURL_ARGS[@]}" 'https://api.github.com/repos/corretto/{corretto-11}/releases'

CORRETTO_VERSIONS=$(jq -r '.[].name' "${TEMP_DIR}/releases-corretto-8.json" "${TEMP_DIR}/releases-corretto-11.json" | sort -V)
for CORRETTO_VERSION in ${CORRETTO_VERSIONS}
do
	for OS in 'linux' 'macosx' 'windows'
	do
		for EXT in $(get_extensions "${OS}")
		do
			for ARCH in $(get_archs "${OS}")
			do
				download "${CORRETTO_VERSION}" "${OS}" "${ARCH}" "${EXT}" || echo "Cannot download $(archive_filename "${CORRETTO_VERSION}" "${OS}" "${ARCH}" "${EXT}")"
			done
		done
	done
done

jq -M -s -S . "${METADATA_DIR}"/amazon-corretto-*.json > "${METADATA_DIR}/releases.json"
for OS in 'linux' 'macosx' 'windows'
do
	for ARCH in $(get_archs "${OS}")
	do
		DIR="${METADATA_DIR}/${OS}/${ARCH}"
		ensure_directory "${DIR}"
		jq -M -S ".[] | select(.os == \"${os}\") | select(.arch == \"${arch}\")" "${METADATA_DIR}/releases.json" > "${DIR}/releases.json"
	done
done
