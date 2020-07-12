# Deprecated: See joschi/java-metadata for a replacement

----

# Amazon Corretto Release Metadata

![Update release metadata](https://github.com/joschi/corretto-metadata/workflows/Update%20release%20metadata/badge.svg)

The update script in this repository collects a list of the currently available [Amazon Corretto](https://aws.amazon.com/corretto/) OpenJDK builds and their metadata to store it as JSON files in the `metadata/` directory in this repository.

Additionally the script stores MD5, SHA-1, SHA-256, and SHA-512 checksums of the artifacts which are compatible with `md5sum`, `sha1sum`, `sha256sum`, and `sha512sum` in the `checksums/` directory in this repository.

## Usage

You can fetch the latest metadata for all Amazon Corretto releases at the following URL:

```
https://github.com/joschi/corretto-metadata/raw/master/metadata/releases.json
```

Example with cURL (requesting a compressed version which significantly reduces the transfer size):

```
curl --compressed -L https://github.com/joschi/corretto-metadata/raw/master/metadata/releases.json
```

If you want to fetch the checksum manifests for a Amazon Corretto release, you can download it with the following URL template:

```
https://github.com/joschi/corretto-metadata/raw/master/checksums/{artifact_filename}.{hash_function}
```

* `artifact_filename`: The original filename of the artifact, for example `amazon-corretto-8.202.08.2-linux-x64.tar.gz`
* `hash_algorithm`: The hash function you want to use; valid values are `md5`, `sha1`, `sha256`, and `sha512`

Example with cURL and SHA-256 checksum:

```
# Download Amazon Corretto 8.202.08.2 for Linux (x64)
curl -O https://d3pxv6yz143wms.cloudfront.net/8.202.08.2/amazon-corretto-8.202.08.2-linux-x64.tar.gz
# Download SHA-256 checksum manifest for Amazon Corretto 8.202.08.2 for Linux (x64)
curl -L -O https://github.com/joschi/corretto-metadata/raw/master/checksums/amazon-corretto-8.202.08.2-linux-x64.tar.gz.sha256
# Verify checksum
sha256sum -c amazon-corretto-8.202.08.2-linux-x64.tar.gz.sha256
```

## Metadata structure

| Field name     | Description                           |
| -------------- | ------------------------------------- |
| `filename`     | Filename of the artifact              |
| `url`          | Full source URL of the artifact       |
| `md5`          | MD5 checksum of the artifact          |
| `md5_file`     | Filename of the MD5 checksum file     |
| `sha1`         | SHA-1 checksum of the artifact        |
| `sha1_file`    | Filename of the SHA-1 checksum file   |
| `sha256`       | SHA-256 checksum of the artifact      |
| `sha256_file`  | Filename of the SHA-256 checksum file |
| `sha512`       | SHA-512 checksum of the artifact      |
| `sha512_file`  | Filename of the SHA-512 checksum file |
| `version`      | Amazon Corretto version               |
| `os`           | `linux`, `macosx`, `windows`          |
| `arch`         | `x64`, `aarch64`                      |
| `archive_type` | `tar.gz`, `zip`, `pkg`, `msi`         |


Example:

```json
{
  "filename": "amazon-corretto-8.202.08.2-linux-x64.tar.gz",
  "url": "https://d3pxv6yz143wms.cloudfront.net/8.202.08.2/amazon-corretto-8.202.08.2-linux-x64.tar.gz",
  "md5": "23a4e82eb9737dfd34c748b63f8119f7",
  "md5_file": "amazon-corretto-8.202.08.2-linux-x64.tar.gz.md5",
  "sha1": "8da77cfbf091d63cf790f0ee5a0ab1c447a7350b",
  "sha1_file": "amazon-corretto-8.202.08.2-linux-x64.tar.gz.sha1",
  "sha256": "c19a928687479e1036ff1d6e023975402d2f027d9b3e4d64cfaf0c9f35bf9669",
  "sha256_file": "amazon-corretto-8.202.08.2-linux-x64.tar.gz.sha256",
  "sha512": "91523409ca9ff78ab4ee133dbd32ca527a4b5b0a448f82d638be36c9d235e7fcabdf37fad2e21ee455873f0e76d61b7ebf18736d75b707d6e1bbbdc646aa2a9c",
  "sha512_file": "amazon-corretto-8.202.08.2-linux-x64.tar.gz.sha512",
  "version": "8.202.08.2",
  "os": "linux",
  "arch": "x64",
  "archive_type": "tar.gz"
}
```

See also [`metadata/`](./metadata/) directory.

## Disclaimer

This project is in no way affiliated with [Amazon Web Services, Inc.](https://aws.amazon.com/) or [Amazon Corretto](https://aws.amazon.com/corretto/).
