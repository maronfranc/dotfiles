#!/usr/bin/env bash
C_1="$C_CYAN"

read -p "${C_1}Enter group name${C_NC} (e.g. com.mycompany.library): " group_name
read -p "${C_1}Enter artifact name${C_NC} (e.g. hiphen-separated-project-words): " artifact_name

# Get current Java version installed.
java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)

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
# web         -> Micronaut MVC / REST API support.
# data-jpa    -> ORM with Hibernate + Spring Data repositories.
# postgres    -> PostgreSQL JDBC driver.
curl -G "https://launch.micronaut.io/create/default/$artifact_name" \
  -d "lang=$language" \
  -d "build=gradle" \
  -d "javaVersion=$java_version" \
  -d "features=data-jpa,jdbc-hikari,postgres" \
  -d "groupId=$group_name" \
  -d "packageName=$package_name" \
  -o "$zip_file"

unzip "$zip_file"
rm -rf "$zip_file"
cd "$artifact_name"
