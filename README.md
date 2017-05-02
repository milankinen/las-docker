# Dockerized SeCo Language Analysis Services

This repository contains a dockerized version of the great [SeCo Language Analysis Services](http://demo.seco.tkk.fi/las/)
Play application. The pre-built image is also available in [Docker Hub](https://hub.docker.com/r/milankinen/seco-las/).

## Quick usage

```bash
$ docker run --rm -p 19990:9000 -t -i milankinen/seco-las 
# "dockerhost" hostname alias points to your docker host machine's address
$ curl 'http://dockerhost:19990/las/baseform?text=Terve+maailmaan!&locale=fi'
# =>
# "terve maailma !"
```

## Memory configuration

By default, the application uses 2G memory which is the absolute minimum requirement - 
smaller amounts cause `OutOfMemoryError` exceptions due to big sizes of the used models.

Memory can be configured by using `LAS_MEMORY` environment variable. The value is integer
describing Java process memory in megabytes, e.g

```bash 
$ docker run --rm -e LAS_MEMORY=4096 -p 19990:9000 -t -i milankinen/seco-las 
```

## API

See [the official documentation](http://demo.seco.tkk.fi/las/).


## License

The dockerfile and build files are licensed under MIT

However, note that the dependencies inside the container have different licenses:

| **Dependency**                                     | **License** |
|----------------------------------------------------|-------------|
| [seco-lexicalanalysis](https://github.com/jiemakel/seco-lexicalanalysis) and [seco-lexicalanalysis-play](https://github.com/jiemakel/seco-lexicalanalysis-play) | MIT        |
| [seco-hfst](https://github.com/jiemakel/seco-hfst)                                                                                                              | Apache-2.0 |
| [HFST](http://hfst.github.io) models                                                                                                                            | GPLv3      |
| [mate-tools](https://code.google.com/archive/p/mate-tools)                                                                                                      | GPLv3      |
| [marmot](https://github.com/muelletm/cistern/tree/master/marmot)                                                                                                | GPLv3      |
