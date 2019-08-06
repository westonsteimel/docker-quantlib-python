# QuantLib with python in Docker
Dockerized environment with [QuantLib](http://quantlib.org) and python based on [Alpine Linux](https://alpinelinux.org).

## Pull command
`docker pull westonsteimel/quantlib-python`

## Usage notes
The following will launch an interactive python interpreter within the dcker container:

`docker run --rm -it --cap-drop all westonsteimel/quantlib-python python`

Everything within the container executes as the non-root `quantlib` user by default
