#!/usr/bin/env bash
set -Eeuo pipefail

ql_versions=( "$@" )
if [ ${#ql_versions[@]} -eq 0 ]; then
	ql_versions=( */ )
fi
ql_versions=( "${ql_versions[@]%/}" )

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
	echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
	echo "$@" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

declare -A python_alpine_versions
python_alpine_versions=( ["3.6"]="3.6;3.7" ["3.5"]="3.6;3.7")
declare -A ql_checksums
ql_checksums=(["1.12"]="aae1f29881fc23f0b8bd85a9730308610974418112ab0d55b2745de9d7c7410a" ["1.13"]="0ab99d6a43b2a204d6366fb600aa3cd049ee29e1d0406fefaedcc0f4fd9c65c2")

for ql_version in "${ql_versions[@]}"; do
    ql_checksum=${ql_checksums[$ql_version]}
    for python_version in ${!python_alpine_versions[@]}; do
        echo "Generating Dockerfiles for QuantLib version ${ql_version} and Python version ${python_version}."
        template=alpine
        echo "Generating templates for ${template}"
        python_lib_path=python${python_version:0:3}
	alpine_versions=(${python_alpine_versions[$python_version]//;/ })

        for alpine_version in ${alpine_versions[@]}; do
	    dockerfile_path=$ql_version/python$python_version/$template/$alpine_version 
	    mkdir -p $dockerfile_path
	    ql_builder_tag=$ql_version-$template$alpine_version
            python_tag=$python_version-$template$alpine_version

	    sed -r \
	        -e 's!%%QL_BUILDER_TAG%%!'"$ql_builder_tag"'!g' \
		-e 's!%%PYTHON_TAG%%!'"$python_tag"'!g' \
	        -e 's!%%QUANTLIB_SWIG_VERSION%%!'"$ql_version"'!g' \
		-e 's!%%QUANTLIB_SWIG_CHECKSUM%%!'"$ql_checksum"'!g' \
		-e 's!%%PYTHON_LIB_PATH%%!'"$python_lib_path"'!g' \
                "Dockerfile-${template}.template" > "$dockerfile_path/Dockerfile"
	    echo "Generated ${dockerfile_path}/Dockerfile"
        done
    done
done
