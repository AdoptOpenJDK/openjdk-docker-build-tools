#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Generate the common license and copyright header
print_legal() {
	cat > $1 <<-EOI
	# ------------------------------------------------------------------------------
	#               NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
	#
	#                       PLEASE DO NOT EDIT IT DIRECTLY.
	# ------------------------------------------------------------------------------
	#
	# Licensed under the Apache License, Version 2.0 (the "License");
	# you may not use this file except in compliance with the License.
	# You may obtain a copy of the License at
	#
	#      http://www.apache.org/licenses/LICENSE-2.0
	#
	# Unless required by applicable law or agreed to in writing, software
	# distributed under the License is distributed on an "AS IS" BASIS,
	# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	# See the License for the specific language governing permissions and
	# limitations under the License.
	#

	EOI
}

# Print the maintainer
print_maint() {
	cat >> $1 <<-EOI
	MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)
	EOI
}

# Print the Java version that is being installed here
print_env() {
	shasums="${package}"_"${vm}"_"${version}"_"${build}"_sums
	jverinfo=${shasums}[version]
	eval jver=\${$jverinfo}

	cat >> $1 <<-EOI

ENV JAVA_VERSION ${jver}

EOI
}

# Print the FROM command for a specific java version
# This will be the base image for the build tool
print_base_java() {
	image_tag=$2

	repo="adoptopenjdk/openjdk${version}"
	if [ "${vm}" != "hotspot" ]; then
		repo="${repo}-${vm}";
	fi

	cat >> $1 <<-EOI
	FROM ${repo}:${image_tag}

	EOI
}

# Print the maven dockerfile install commands
print_maven() {
	cat >> $1 <<'EOI'

ARG MAVEN_VERSION="3.6.3"
ARG USER_HOME_DIR="/root"
ARG SHA="26ad91d751b3a9a53087aefa743f4e16a17741d3915b219cf74112bf87a438c5"
ARG BASE_URL="https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries"

RUN mkdir -p /usr/share/maven \
    && curl -Lso  /tmp/maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${SHA}  /tmp/maven.tar.gz" | sha256sum -c - \
    && tar -xzC /usr/share/maven --strip-components=1 -f /tmp/maven.tar.gz \
    && rm -v /tmp/maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "${USER_HOME_DIR}/.m2"

CMD ["/usr/bin/mvn"]
EOI
}

# Generate a build tool dockerfile for the given file and tag
generate_build_tool_dockerfile() {
	file=$1
	image_tag=$2

	mkdir -p `dirname ${file}` 2>/dev/null
	echo
	echo -n "Writing ${file} ... "

	print_legal ${file};
	print_base_java ${file} ${image_tag}
	print_maint ${file};
	print_${tool} ${file};
	echo "done"
	echo
}

# Create the build tools dockerfiles
function create_build_tool_dockerfiles() {
	tool=$1;
	vm=$2;
	os=$3;
	build=$4;
	btype=$5;

	# Get the tag alias to generate the build tools Dockerfiles
	build_tags ${vm} ${os} ${build} ${btype}
	# build_tags populates the array tag_aliases, but we just need the first element
	# The first element corresponds to the tag alias
	tags_arr=(${tag_aliases});
	tag_alias=${tags_arr[0]};

	tool_dir=$(parse_config_file ${tool} ${version} ${os} "Directory:")
	file=${tool_dir}/Dockerfile.${vm}.${build}.${btype}
	generate_build_tool_dockerfile ${file} ${tag_alias}
}
