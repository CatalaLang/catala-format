#!/bin/sh
set -euC

usage () {
    cat <<EOF
Usage: $0 --query-file DIR --output-file FILE --topiary-wrapped FILE

  --help                     Show this help and quit
  --query-file DIR          Where the queries files are installed
  --config-file FILE         Where the config file is installed
  --output-file FILE         Where to put the generated wrapper
  --topiary-wrapped FILE     Where the wrapped Topiary binary is installed
EOF
}

die () {
    printf >&2 "$@"
    printf '\n'
    usage
    exit 2
}

query_file=
config_file=
output_file=
topiary_wrapped=

while [ $# -gt 0 ]; do
    arg=$1
    shift

    case $arg in
        --query-file)
            query_file=$1
            shift
            ;;

        --config-file)
            config_file=$1
            shift
            ;;

        --output-file)
            output_file=$1
            shift
            ;;

        --topiary-wrapped)
            topiary_wrapped=$1
            shift
            ;;

        --help)
            usage
            exit 0
            ;;

        *)
            die 'Error: I do not know what to do with argument `%s`.\n' "$arg"
    esac
done

[ -z "$query_file" ] && die 'Error: You need to specify --query-file.\n'
[ -z "$config_file" ] && die 'Error: You need to specify --config-file.\n'
[ -z "$output_file" ] && die 'Error: You need to specify --output-file.\n'
[ -z "$topiary_wrapped" ] && die 'Error: You need to specify --topiary-wrapped.\n'

[ "${query_file% *}" != "$query_file" ] && die 'Error: --query-file cannot contain spaces.\n'
[ "${config_file% *}" != "$config_file" ] && die 'Error: --config-file cannot contain spaces.\n'
[ "${topiary_wrapped% *}" != "$topiary_wrapped" ] && die 'Error: --topiary-wrapped cannot contain spaces.\n'

export topiary_wrapped config_file query_file
cat script.template.sh > $output_file

# Concat the fully resolved command
echo "$topiary_wrapped --configuration $config_file format" \
      '--language $CATALA_LANG' \
      "--query $query_file" \
      '< "${INPUT_FILE:-/dev/stdin}"' >> $output_file

chmod +x "$output_file"
