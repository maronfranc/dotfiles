#!/usr/bin/env bash

C_1="$C_CYAN"

read -p "${C_1}Enter group name${C_NC} (e.g. com.mycompany.library): " group_name
read -p "${C_1}Enter artifact name${C_NC} (e.g. hiphen-separated-project-words): " artifact_name

# Get current Java version installed.
java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
# java_versions_available=$(curl -s https://start.spring.io \
#     -H "Accept: application/vnd.initializr.v2.1+json" |
#     jq -r '[.javaVersion.values[].id] | join(",")')

read -p "${C_1}Enter language [default java]${C_NC} (options: java,kotlin): " language
language=${language:-java}

package_name="${group_name}.${artifact_name//-/.}"
zip_file="${artifact_name}.zip"

if [ -f "$zip_file" ]; then
    echo "Error: $zip_file already exists. Aborting to avoid overwrite."
    return 1
fi

echo "Using package name: $package_name"
echo "Java version: $java_version | Language: $language"

# Dependencies:
# web         -> Spring MVC / REST API support.
# data-jpa    -> ORM with Hibernate + Spring Data repositories.
# postgresql  -> PostgreSQL JDBC driver.
curl https://start.spring.io/starter.zip \
    -d dependencies=web,data-jpa,postgresql \
    -d type=gradle-project \
    -d language="$language" \
    -d javaVersion="$java_version" \
    -d baseDir="$artifact_name" \
    -d artifactId="$artifact_name" \
    -d groupId="$group_name" \
    -d packageName="$package_name" \
    -o "$zip_file"

unzip "$zip_file"
rm -rf "$zip_file"
cd "$artifact_name"
