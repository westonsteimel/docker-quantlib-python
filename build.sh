#!/usr/bin/env bash
set -Eeuo pipefail

versions=( "$@" )
if [ "${#versions[@]}" -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
	echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
	echo "$@" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

declare -A python_alpine_versions
python_alpine_versions=(["3.7"]="3.8;3.9"  ["3.6"]="3.8;3.9" ["3.5"]="3.8;3.9")
latest_alpine=3.9
latest_python=3.7
latest_ql=1.15
imagebase="westonsteimel/quantlib-python"
repos=("" "quay.io")

for version in "${versions[@]}"; do
    for python_version in "${!python_alpine_versions[@]}"; do
        echo "Building Dockerfiles for QuantLib version ${version} and Python version ${python_version}."
        template=alpine
        alpine_versions=(${python_alpine_versions[$python_version]//;/ })
        
        for alpine_version in "${alpine_versions[@]}"; do
            (
            cd "${version}/python${python_version}/${template}/${alpine_version}"
            build_tag="${imagebase}:${version}-python${python_version}-${template}${alpine_version}"
            echo "Building ${build_tag}..."
            time docker build --build-arg "CONCURRENT_PROCESSES=4" -t "${build_tag}" .

            for repo in "${repos[@]}"; do 
                repobase="${imagebase}"
                if [ "$repo" != "" ]; then
                    repobase="${repo}/${imagebase}"
                fi
                docker tag "${build_tag}" "${repobase}:${version}-python${python_version}-${template}${alpine_version}"
                if [ "${alpine_version}" = "${latest_alpine}" ] ; then
                    docker tag "${build_tag}" "${repobase}:${version}-python${python_version}"
                    docker tag "${build_tag}" "${repobase}:${version}-python${python_version}-${template}"
                fi
                if [ "${python_version}" = "${latest_python}" ] ; then
                    docker tag "${build_tag}" "${repobase}:${version}-${template}${alpine_version}"
                    if [ "${alpine_version}" = "${latest_alpine}" ] ; then
                        docker tag "${build_tag}" "${repobase}:${version}-${template}"
                        docker tag "${build_tag}" "${repobase}:${version}"
                        docker tag "${build_tag}" "${repobase}:${version}-python3"
                    fi
                fi
                if [ "${version}" = "${latest_ql}" ] ; then
                    docker tag "${build_tag}" "${repobase}:python${python_version}-${template}${alpine_version}" 
                fi
	            if [ "${version}" = "${latest_ql}" ] && [ "${python_version}" = "${latest_python}" ] ; then
                    docker tag "${build_tag}" "${repobase}:${template}${alpine_version}"
                fi
                if [ "${version}" = "${latest_ql}" ] && [ "${alpine_version}" = "${latest_alpine}" ]; then
                    docker tag "${build_tag}" "${repobase}:python${python_version}"
                    docker tag "${build_tag}" "${repobase}:python${python_version}-${template}"
                fi
                if [ "${version}" = "${latest_ql}" ] && [ "${python_version}" = "${latest_python}" ] && [ "${alpine_version}" = "${latest_alpine}" ]; then
                    docker tag "${build_tag}" "${repobase}:latest"
                    docker tag "${build_tag}" "${repobase}:${template}"
                    docker tag "${build_tag}" "${repobase}:python3"
                    docker tag "${build_tag}" "${repobase}:${version}-python3"
                fi
            done
            )
        done
    done
done
