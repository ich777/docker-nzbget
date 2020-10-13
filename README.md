# NZBGet in Docker optimized for Unraid
NZBGet is an Usenet-client written in C++ and designed with performance in mind to achieve maximum download speed by using very little system resources.

**UPDATE:** The container will check on every start/restart if there is a newer version available (you can also choose between stabel and prereleases and switch between them - keep in mind sometimes downgrading from a prerelease version could break your configuration).

**MANUAL VERSION:** You can also set a version manually by typing in the version number that you want to use for example: '21.0' without quotes - this does only work with release versions.

**ATTENTION:** Don't change the IP address or the port in the nzbget config itself.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for configfiles and the application | /nzbget |
| NZBGET_V | Select if you want to download a stable or prerelease | latest |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value for new created files | 0000 |
| DATA_PERMS | Data permissions for config folder | 770 |

## Run example
```
docker run --name NZBGet -d \
	-p 6789:6789 \
	--env 'NZBGET_V=latest' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=0000' \
	--env 'DATA_PERMS=770' \
	--volume /mnt/cache/appdata/nzbget:/nzbget \
	--volume /mnt/user/Downloads:/mnt/downloads \
	ich777/nzbget
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!
 
#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/