#!/bin/sh
set -euC

usage () {
    cat <<EOF
Usage: $0 [CATALA-FILE] [OPTIONS]

Format the given CATALA-FILE and output the result.
When no CATALA-FILE is provided, the standard input will be read
however the --language argument becomes mandatory.

  --help                     Show this help and quit
  -l <lang>
  --language <lang>          Configure the formatting parser's language.
                             Possible values are: 'catala_en', 'catala_fr' or 'catala_pl'.
EOF
}

die () {
    printf >&2 "$@"
    printf '\n'
    usage
    exit 2
}

CATALA_LANG=""
INPUT_FILE=""

while [ $# -gt 0 ]; do
    arg=$1
    shift

    case $arg in
        --language|-l)
            CATALA_LANG=$1
            shift
            ;;

        --help)
            usage
            exit 0
            ;;

        *)
            if [ "$INPUT_FILE" = "" ]; then
                INPUT_FILE=$arg
                if ! [ -f $INPUT_FILE ]; then
                    die "Given input file '%s' is not a regular file" "$arg"
                fi
            else
                die 'Multiple input file arguments provided. Expected only one.'
            fi
    esac
done

if [ "$CATALA_LANG" = "" ]; then
    extension="${INPUT_FILE##*.}"
    case $extension in
        "catala_en"|"catala_fr"|"catala_pl")
            CATALA_LANG=$extension
            ;;
        *)
            die "Cannot infer the parser's language.\nYou can manually set it with the --language option."
    esac
else
    case $CATALA_LANG in
        "catala_en"|"catala_fr"|"catala_pl")
            break
            ;;
        *)
            die "Invalid specified language '%s'.\nPossible values are 'catala_en', 'catala_fr' or 'catala_pl'." "$CATALA_LANG"
    esac
fi

# Evaluated invokation is generated here
