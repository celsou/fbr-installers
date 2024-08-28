#!/bin/bash

# NOTE: some comments may be grammatically wrong, because
# the developer of the installer does not speak English

####################################################
###            FUNCTION DEFINITIONS              ###
####################################################


# Print 3 blank lines in terminal
function breaklines {
	echo; echo; echo
}

# Verify installation files
function check_files {
	if [[ ! -d "$FBR_DIR" ]]; then
		echo "Current folder: $PWD"
		echo "Error: FBR installer files not found! Exiting."
		exit 1
	fi
}

# Search for ScadaBR/Scada-LTS installations in commonly used folders
function find_scada {
	# Global variable: founded ScadaBR/-LTS installations
	declare -ag found_installations
	
	# Search in common installation directories	
	declare -a search_path
	search_path=("/opt/ScadaBR/tomcat/webapps/ScadaBR"
				 "/opt/ScadaBR/tomcat/webapps/Scada-LTS"
				 "/var/lib/tomcat9/webapps/Scada-LTS"
				 "/var/lib/tomcat9/webapps/ScadaBR"
				 "/var/lib/tomcat8/webapps/ScadaBR"
				 "/var/lib/tomcat7/webapps/ScadaBR"
				 "/var/lib/tomcat6/webapps/ScadaBR"
				 "/opt/ScadaBR-EF/tomcat/webapps/ScadaBR"
				 "/opt/tomcat6/apache-tomcat-6.0.53/webapps/ScadaBR")		
		
	for folder in "${search_path[@]}"; do
		if [[ -d "$folder" ]]; then
			found_installations+=("$folder")
		fi
	done
	
	# Search in parent folder
	cd "${CURRENT_DIR}/.."
	local_search=$(ls "$PWD" | grep -i "Scada-LTS_.*_Installer_.*Setup$" | find -type f -name "view.js" -printf "%P;" | sed 's:/resources/view.js::g')
	local_search_dir=$(echo $PWD)
	cd "${CURRENT_DIR}"	
	
	rest="${local_search}"
	while [[ -n "$rest" ]]; do
		local_search=$(grep -o "^[^;]*" <<< $rest)
		rest=$(sed 's:^[^;]*;::' <<< $rest)
		found_installations+=("${local_search_dir}/${local_search}")
	done
}


# Select where to install FBR [user interaction]
function select_install_folder {
	echo "=== Installation folder selection ==="
	echo "Please select where to install FBR:"
	echo ""
	echo "0) Customize installation path"
	
	for i in "${!found_installations[@]}"; do
		j=$((i + 1))
		echo "$j) ${found_installations[$i]}"	
	done

	echo ""
	until [[ "$code" =~ ^[0-9]+$ ]] && [[ $code -le $j ]]; do
		read -p "Please select one of the option numbers above: " code
		echo ""
	done
	
	if [[ $code -eq 0 ]]; then
		customize_install_folder
	else
		j=$((code - 1))
		INSTALL_DIR="${found_installations[$j]}"
	fi	
}

# Customize installation folder [user interaction]
function customize_install_folder {
	read -p "Insert custom path to ScadaBR/Scada-LTS: " path
	
	until validate_install_folder; do
		echo "This path is not from a valid ScadaBR/-LTS installation."
		echo ""
		read -p "Please insert a valid path: " path
	done
	INSTALL_DIR=$(find "$path" -type f -name "view.js" | sed 's:/resources/view.js::')	
}

# Validate if a given installation folder contains ScadaBR/Scada-LTS
function validate_install_folder {
	if [[ -d "${path}/tomcat/server/webapps/Scada-LTS" ]] ||
	   [[ -d "${path}/tomcat/webapps/Scada-LTS" ]] ||
	   [[ -d "${path}/tomcat/webapps/ScadaBR" ]] ||
	   [[ -d "${path}/webapps/ScadaBR" ]] ||
	   [[ -d "${path}/webapps/Scada-LTS" ]] ||
	   [[ -f "${path}/resources/view.js" ]]
	then
		return 0
	else
		return 1
	fi
}

# Select language to use in FBR interface [user interaction]
function select_language {	
	echo
	echo "=== Language selection ==="
	echo "Please select in which language FBR will be translated:"
	echo
	echo "1) English [default]"
	echo "2) Português (Portuguese)"
	echo "3) Español (Spanish)"
	echo
	read -p "Type a number or ENTER to use default [English]: " lang
	echo
	
	case $lang in
		2) # Portuguese
			FBR_LANG_CODE=pt
			echo "* Portuguese language selected"
		;;
		
		3) # Spanish
			FBR_LANG_CODE=es
			echo "* Spanish language selected"
		;;
		
		1 | *) # English
			FBR_LANG_CODE=en
			echo "* English language selected"
		;;
	esac	
}

# Detect other versions of FBR previously installed
function detect_previous_installations {
	if [[ -d "${INSTALL_DIR}/resources/fuscabr" ]] ||
	   [[ -f "${INSTALL_DIR}/resources/fuscabr.js" ]]
	then
		# Another version founded
		return 0
	fi	
	
	# Another version not founded
	return 1
}

# Determines if user wants to update or remove FBR [user interaction]
function modify_or_uninstall {
	echo "=== Version management ==="
	echo "Another version of FBR is already installed in this computer."
	echo "What do you want to do?"
	echo ""
	echo "1) Exit setup [default]"
	echo "2) Update to FBR ${FBR_VERSION} (this will remove other versions)"
	echo "3) Uninstall FBR"
	echo ""
	read -p "Type a number or ENTER to use default: " code
	echo ""

	case $code in
		3) # Uninstall
			echo "* FBR will be uninstalled"
			return ${UNINSTALL_ID}
		;;
		
		2) # Update
			echo "* FBR will be updated"
			return ${MODIFY_ID}
		;;
		
		1 | *) # Exit without changes			
			echo "* FBR installation aborted by user. Exiting."
			exit 1
		;;
	esac
}

# Determines if setup is running on a Scada-LTS installation
function is_scada_lts {
	if [[ -d "${INSTALL_DIR}/WEB-INF/classes/org/scada_lts" ]] &&
	   [[ -f "${INSTALL_DIR}/WEB-INF/tags/page.tag" ]]; then
	  return 0
	fi

	return 1
}

# Asks if user wants to configure FBR for Scada-LTS
function configure_for_lts {
	echo "The installer detected you are using Scada-LTS."
	echo ""
	read -p "Do you want to configure FBR installation for Scada-LTS? (Y/n): " code
	echo ""
	
	case $code in
		"n" | "N" |	"NO" | "no" | "No" | "nO")
			
			echo "* The installer will NOT configure FBR for Scada-LTS"
			return 1
		;;
		
		*)			
			echo "* The installer will configure FBR for Scada-LTS"
			return 0
		;;
	esac
}

# Copy FBR files into installation directory
function copy_fbr {
	
	if [[ -f "${INSTALL_DIR}/resources/fuscabr.js" ]]; then
		rm -f "${INSTALL_DIR}/resources/fuscabr.js"
	fi
	# Copy main folder
	cp -rf "${FBR_DIR}" "${INSTALL_DIR}/resources"
}

# Register FBR in ScadaBR/-LTS JSP files
function register_fbr {
	# Delete old script entries
	sed -E -i.bak 's:< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>::' "${INSTALL_DIR}/WEB-INF/tags/page.tag"
	sed -E -i.bak 's:< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>::' "${INSTALL_DIR}/WEB-INF/jsp/publicView.jsp"
	# Create new script entries
	sed -i '/<script.*common.js.*$/ a <script src="resources\/fuscabr\/fuscabr.js" defer><\/script>' "${INSTALL_DIR}/WEB-INF/tags/page.tag"
	sed -i '/<script.*common.js.*$/ a <script src="resources\/fuscabr\/fuscabr.js" defer><\/script>' "${INSTALL_DIR}/WEB-INF/jsp/publicView.jsp"
	# Change FUScaBR language
	sed -i -E "s/(.*\"language\".*\")en(\".*)/\1${FBR_LANG_CODE}\2/" "${INSTALL_DIR}/resources/fuscabr/conf/common.json"
	sed -i -E "s/(.*\"languageFile\".*)en(.json.*)/\1${FBR_LANG_CODE}\2/" "${INSTALL_DIR}/resources/fuscabr/conf/common.json"
	# Configure servlet mappings (only needed for Scada-LTS)
	[[ "$install_for_lts" == "yes" ]] && configure_servlet
}

# Configures Scada-LTS servlets in the web.xml file
function configure_servlet {
	echo "Scada-LTS configuration..."
	
	declare -a file_extensions
	file_extensions=('*.js' '*.json' '*.html' '*.css')
		
	for extension in "${file_extensions[@]}"; do
		e=$(sed -e 's/[*]/\\*/' -e 's/[.]/\\./' <<< "$extension")
		regex="(?s)<servlet-mapping>\s*<servlet-name>\w*</servlet-name>\s*<url-pattern>${e}</url-pattern>\s*</servlet-mapping>"
		
		if ! grep -Pzq "$regex" "${INSTALL_DIR}/WEB-INF/web.xml"; then
			sed  -i.bak "/<\/web-app>/ i \  <servlet-mapping>\n    <servlet-name>default<\/servlet-name>\n    <url-pattern>${extension}</url-pattern>\n  <\/servlet-mapping>" "${INSTALL_DIR}/WEB-INF/web.xml"
			echo "   - Mapped ${extension} to default servlet"
		fi
	done
}

function uninstall_fbr {
	# Delete old script entries
	echo "Unregistering FBR from .jsp files..."
	sed -i 's:< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>::' "${INSTALL_DIR}/WEB-INF/tags/page.tag"
	sed -i 's:< ?script[^>]*src=.resources/(fuscabr/)?fuscabr\.js.[^>]*>[^<]*?</ ?script ?>::' "${INSTALL_DIR}/WEB-INF/jsp/publicView.jsp"
	# Remove FBR directory
	echo "Removing FBR files..."
	rm -rf "${INSTALL_DIR}/resources/fuscabr"
}


####################################################
###                MAIN SCRIPT                   ###
####################################################


# Global Constants
FBR_VERSION="2.1.1"
FBR_DIR="fuscabr"
CURRENT_DIR="$PWD"
MODIFY_ID=2
UNINSTALL_ID=3

# Request root privileges
if [[ "$EUID" -ne 0 ]]; then
	echo "This script must be run as root"
	echo "Usage:"
	echo "    sudo $0"
	echo "    sudo $0 <custom_installation_path>"
	exit
fi

breaklines
echo "Welcome to the FBR $FBR_VERSION installer!"
breaklines

# Verify installation files
check_files

## Set installation directory
if [[ -n "$1" ]]; then
	path="$1"
	
	if validate_install_folder;  then
		INSTALL_DIR=$(find "$path" -type f -name "view.js" | sed 's:/resources/view.js::')
	else
		echo "Error: $1 does not exists or is not a directory"
		exit 1
	fi
else	
	find_scada
	select_install_folder
fi

echo "* FBR installation folder: ${INSTALL_DIR}"

if detect_previous_installations; then
	
	breaklines
	modify_or_uninstall	
	if [[ $? -eq $UNINSTALL_ID ]]; then
		# Uninstall FBR
		uninstall_fbr
		echo ""
		echo "FBR was uccessfully uninstalled!"
		echo "Thank you!"
		exit 0
	fi
fi

breaklines
select_language

breaklines
if is_scada_lts && configure_for_lts; then
	install_for_lts="yes"
fi

breaklines
echo "Copying FBR files..."
copy_fbr
echo "Configuring FBR..."
register_fbr

echo ""
echo "FBR $FBR_VERSION was installed successfully."
echo "Enjoy it!"
echo "---"
breaklines
echo "(remember to clear browser's cache after installing FBR)"
