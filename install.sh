#!/usr/bin/env bash
#  Copyright (c) 2018-2019. Prasad Tengse
#

# Installs dotfiles
# Probably this script is shitty and  specific to my setup.
# More generic solutions would be to use one of the tools mentioned in.
# https://wiki.archlinux.org/index.php/Dotfiles#Tools
# But most of them require Perl or python. Though
# most systems have those installed by default, I wanted something
# which was dependent only on bash/zsh

set -o pipefail

#Constants
readonly DATE=$(date +%Y-%m-%d:%H:%M:%S)
readonly SCRIPT=$(basename "$0")
readonly YELLOW=$'\e[33m'
readonly GREEN=$'\e[32m'
readonly RED=$'\e[31m'
readonly BLUE=$'\e[34m'
readonly NC=$'\e[0m'
readonly CURDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
readonly spacing_string="%+11s"
readonly LOGO="   [0;1;31;91m_[0;1;33;93m__[0m       [0;1;35;95m_[0;1;31;91m_[0m  [0;1;33;93m_[0;1;32;92m__[0;1;36;96m__[0m [0;1;34;94m_[0;1;35;95m_[0m
  [0;1;33;93m/[0m [0;1;32;92m_[0m [0;1;36;96m\_[0;1;34;94m__[0m  [0;1;31;91m/[0m [0;1;33;93m/_[0;1;32;92m/[0m [0;1;36;96m__[0;1;34;94m(_[0;1;35;95m)[0m [0;1;31;91m/_[0;1;33;93m_[0m [0;1;32;92m__[0;1;36;96m_[0m
 [0;1;33;93m/[0m [0;1;32;92m/[0;1;36;96m/[0m [0;1;34;94m/[0m [0;1;35;95m_[0m [0;1;31;91m\/[0m [0;1;33;93m_[0;1;32;92m_/[0m [0;1;36;96m_[0;1;34;94m//[0m [0;1;35;95m/[0m [0;1;31;91m/[0m [0;1;33;93m-[0;1;32;92m_|[0;1;36;96m_-[0;1;34;94m<[0m
[0;1;32;92m/_[0;1;36;96m__[0;1;34;94m_/[0;1;35;95m\_[0;1;31;91m__[0;1;33;93m/\[0;1;32;92m__[0;1;36;96m/_[0;1;34;94m/[0m [0;1;35;95m/_[0;1;31;91m/_[0;1;33;93m/\[0;1;32;92m__[0;1;36;96m/_[0;1;34;94m__[0;1;35;95m/[0m
"

function display_usage()
{
#Prints out help menu
cat <<EOF
$LOGO
Usage: ${GREEN}${SCRIPT} ${BLUE}  [options]${NC}
---------------------------------------------
[-i --install]         [Install dotfiles]
[-c --no-config]       [Skip Configs in config]
[-C --only-config]     [Only install config files]
[-b --skip-bin]        [Skip installing bins]
[-B --only-bin]        [Only install bins]
[-f --no-fonts]        [Skip Installing fonts]
[-x --default-name]    [Fallback to default config name(hpc)]
[-m --minimal]         [Only install bash and starship config]
[-n --name]            [Name of the config]
[-h --help]            [Display this help message]
[-v --version]         [Display version info]

${YELLOW}Notes on --name parameter${NC}
---------------------------------------------
* If a config specific file or directory is not found,
  It is,
    a] Skiped for Git, GNUPG, BASH
    b] Default is used for configs
${YELLOW}* If -x or --default-name parameter is used, name parameter is
  ignored.

${YELLOW}Notes on file removal/rename${NC}
--------------------------------------------
* If files are deleted/renamed in this repo, symlinks will become broken,
 if you had them already. In such cases remove the broken symlinks manually
 or install the files again or both.

Github repo link : ${BLUE}https://github.com/tprasadtp/dotfiles${NC}
Version          : ${BLUE}${VERSION}${NC}
EOF
}

function print_info()
{
  printf "➜ %s \n" "$@"
}

function print_success()
{
  printf "%s✔ %s %s\n" "${GREEN}" "$@" "${NC}"
}

function print_warning()
{
  printf "%s⚠ %s %s\n" "${YELLOW}" "$@" "${NC}"
}

function print_error()
{
   printf "%s✖ %s %s\n" "${RED}" "$@" "${NC}"
}

function print_notice()
{
  printf "%s✦ %s %s\n" "${BLUE}" "$@" "${NC}"
}

function __link_files()
{
  # Liks files inside a directory to specified destination
  # Arg-1 Input directory
  # Arg 2 Output dir to place symlinks
  # Always .md .git .travis.yml are ignored.
  # This operation is NOT recursive.

  local src="${1}"
  local dest="${2}"

#  echo "SRC : $src"
#  echo "DEST: $dest"
#  echo "CURDIR : $CURDIR"

  if [ -d "${CURDIR}/${src}" ]; then
    if mkdir -p "${INSTALL_PREFIX}/${dest}"; then
      while IFS= read -r -d '' file
      do
        f="$(basename "$file")"
        if ln -sfn "$file" "${INSTALL_PREFIX}/${dest}/${f}"; then
          print_success "Linked : ${f}"
        else
          print_error "Linking ${f} failed!"
        fi
      done< <(find "$CURDIR/${src}" -maxdepth 1  -not -name "$(basename "$src")" -not -name '*.md' -not -name '.travis.yml' -not -name '.git' -not -name 'LICENSE'  -not -name '.editorconfig' -print0)
    else
      print_error "Failed to create destination : $dest"
    fi # mkdir
    else
      print_error "Directory ${src} not found!"
  fi # src check

}



function minimal_install()
{
    # Installs only minimal dotfiles
    # git, zsh, bash and gpg
    # Rest all files are ignored.

    # .bash_profile
    if [[ -f ${CURDIR}/bash/.bash_profile ]]; then
      if ln -sf "${CURDIR}"/bash/.bash_profile "${INSTALL_PREFIX}"/.bash_profile || print_error "Linking failed!"; then
        print_success "Linked : .bash_profile"
      else
        print_error "Linking .bash_profile failed!"
      fi #ln check
    else
      print_error "File .bash_profile was not found!"
    fi

		# Git
		if [[ ${minimal_install} != "true" ]]; then

		# skip git config if -m was passed. this is different from upstream

    # First check for config specific directory
    if [[ -d $CURDIR/git/$config_name ]] && [[ -f $CURDIR/git/$config_name/.gitconfig ]];then
      print_info "GIT Profile : ${config_name}"
      if ln -fs "$CURDIR"/git/"$config_name"/.gitconfig "$INSTALL_PREFIX"/.gitconfig; then
        print_success "Linked : .gitconfig"
      else
        print_error "Linking failed!"
      fi
    # If no config specific dirs are found, use default `git`
    else
      print_error "GIT    :  No config found!"
    fi

		fi # micro

    # Bash
    # First check for config specific directory
    if [[ -d $CURDIR/bash/$config_name ]];then
      print_info "BASH Profile : ${config_name}"
      __link_files "bash/${config_name}" ""
    # If no config specific dirs are found, use default `bash`
    else
      print_error "BASH   :  No config found!"
    fi

    # GPG
		if [[ ${minimal_install} != "true" ]]; then

    # First check for config specific directory
    if [[ -d $CURDIR/gnupg/${config_name} ]];then
      print_info "GNUPG  Profile : ${config_name}"
      __link_files "gnupg/$config_name" ".gnupg/"
    # If no config specific dirs are found, use default `gnupg`
    else
      print_error "GNUPG  : No config found!"
    fi

		fi # minimal_install

		if [[ ${minimal_install} == "true" ]]; then
			__install_config_files "starship" ".config"
		fi

}



function __install_config_files()
{
  if [[ $# -lt 2 ]]; then
    print_error "Invalid number of arguments "
    exit 21;
  fi

  cfg_dir="$1"
  dest_dir="$2"

  # First check for config specific directory
  if [[ -d $CURDIR/config/$cfg_dir-$config_name ]];then
    print_notice "Using config/${cfg_dir} (${config_name})"

    cfg_dir="${cfg_dir}-${config_name}"
  # If no config specific dirs are found, use default config
  elif [[ -d $CURDIR/config/$cfg_dir ]];then
    print_notice "Using config/${cfg_dir} (default)"
  else
    print_error "No configs found for ${cfg_dir}"
    exit 21
  fi


  if mkdir -p "$INSTALL_PREFIX"/"$dest_dir"; then
    # destination path is prefixed with INSTALL_PREFIX automatically
    __link_files "config/$cfg_dir" "$dest_dir"
  else
    print_error "Failed to create $dest_dir directory."
    print_error "$cfg_dir will not be installed!"
  fi
}

function install_config_files()
{
  # Installs files in config to .config
  # Easy way clould be to use gnu stow.
  # But Its not installed by default.

  # Starship
  __install_config_files "starship" ".config"

  # Direnv
  __install_config_files "direnv" ".config/direnv"

	# VNC
	__install_config_files "vnc" ".vnc"

}


function install_bin_shims()
{
	# bin shims
	__link_files "bin" "bin"
}

function install_fonts()
{
  print_info "Installing fonts..."
  if mkdir -p "$INSTALL_PREFIX"/.local/share; then
	  if ln -snf "$CURDIR"/fonts "$INSTALL_PREFIX"/.local/share/fonts; then
      print_success "Fonts installed successfully!"
    else
      print_error "Failed to link fonts to .local/share/fonts"
    fi
  else
    print_error "Failed to create fonts directory. Fonts will not be linked!"
  fi
}


function main()
{
  #check if no args
  if [ $# -lt 1 ]; then
    print_error "No arguments/Invalid number of arguments See usage below."
    display_usage;
    exit 1;
  fi;

  INSTALL_PREFIX="${HOME}"

  while [ "${1}" != "" ]; do
    case ${1} in
      -i | --install )      action_install="true"
                            ;;
      -n | --name )         shift;
                            config_name="${1}";
                            ;;
      -h | --help )         display_usage;
                            exit $?
                            ;;
      -x | --default-name)  use_default_name="true"
                            ;;
      -m | --minimal)       minimal_install="true";
                            ;;
      -f | --no-fonts)      skip_fonts="true";
                            ;;
      -C | --only-config)   only_config="true";
                            ;;
      -c | --no-config)     skip_config="true";
                            ;;
      -B | --only-bin)      only_bin="true";
                            ;;
      -b | --skip_bin)      skip_bin="true";
                            ;;
      -T | --test-mode)     INSTALL_PREFIX="${HOME}/Junk";
                            print_warning "Test mode is active!";
                            print_warning "Files will be installed to ${INSTALL_PREFIX}";
                            mkdir -p "${INSTALL_PREFIX}" || exit 31
                            ;;
      * )                   print_error "Invalid argument(s). See usage below."
                            usage;
                            exit 1
                            ;;
    esac
    shift
  done



  if [[  $action_install == "true" ]]; then

    if [[ $use_default_name == "true" ]]; then
      config_name="hpc";
      print_info "Using default config name";
    fi

		# Check if config name is empty
    if [[ $config_name == "" ]]; then
      print_error "No config name specified"
      exit 10
    fi

    if [[ $only_config == "true" ]]; then
      if [[ $skip_config == "true" ]]; then
        print_error "Option conflicts!"
        exit 1
      fi
      print_notice "Only config files will be installed."
      install_config_files
      exit $?
    fi

		# bin
		if [[ $only_bin == "true" ]]; then
      print_info "Installing scripts to ${INSTALL_PREFIX}/bin"
      install_bin_shims
			exit $?
    fi

    # Minimal checks
    if [[ ${minimal_install} == "true" ]]; then
      print_notice "Minimal install is set to True."
      minimal_install;
    else

      minimal_install;

      #check config skip flag
      if [[ $skip_config == "true" ]]; then
        print_notice ".config files will not be installed."
      else
        print_info "Installing config files..."
        install_config_files
      fi

			# bin
			if [[ $skip_bin == "true" ]]; then
        print_notice "Not installing scipts from bin"
      else
        print_info "Installing scripts to ${INSTALL_PREFIX}/bin"
        install_bin_shims
      fi

      # check fonts
      if [[ $skip_fonts == "true" ]]; then
        print_notice "Skipping fonts installation"
      else
        install_fonts;
      fi

    fi # end of minimal if

  else
    print_error "Did you forget to pass -i | --install?"
    exit 10
  fi

}

#
main "$@"
