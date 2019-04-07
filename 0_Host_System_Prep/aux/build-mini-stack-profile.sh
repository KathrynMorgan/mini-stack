#!/bin/bash

load_vars () {
project_NAME="mini-stack"
base_PATH="$HOME/.config/ccio"
full_PATH="${base_PATH}/${project_NAME}"
profile_TARGET="${full_PATH}/profile"

# Check/Create Directory Path
[[ -f ${full_PATH} ]] || mkdir -p ${full_PATH}
}

user_prompt () {
echo "    Please configure a supported service with your username & ssh public keys
    Supported options:
      GitHub     (enter 'gh')
      Launchpad  (enter 'lp')"
read -p '    gh/lp : ' ssh_service_choice
read -p '    username: ' ssh_uname_choice
}

write_profile () {
cat <<EOF > ${profile_TARGET}
export ssh_service=${ssh_service_choice}   # OPTIONS launchpad:lp github:gh
export ssh_uname=${ssh_uname_choice}
echo ">>>> CCIO Profile Loaded!"
EOF
}

info_print () {
echo "
    CCIO mini-stack profile written to ${profile_TARGET}
    Run the following command to load this profile:
      source ~/.config/ccio/mini-stack/profile
    "
}

req_source_profile () {
echo "    Would you like to load the profile now?"
while true; do
read -p '    [Yes/No]: ' load_PROFILE
    case ${load_PROFILE} in
        [Yy]* ) echo "";
                source ~/.config/ccio/mini-stack/profile; 
                break;;
        [Nn]* ) exit;;
        *     ) echo "Please answer 'yes' or 'no'"
    esac
done
}

load_vars
user_prompt
write_profile
info_print
req_source_profile
