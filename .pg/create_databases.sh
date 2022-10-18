 #!/usr/bin/env bash

export K3D_DB=${K3D_DB-k3d}
export KONG_DB=${KONG_DB-kong}
export HARBOR_DB=${HARBOR_DB-harbor}

for i in "$K3D_DB" "$KONG_DB" "$HARBOR_DB"
do
    if [ -f "/run/secrets/$i_PW" ]; then
        export "${i}_PW=$(echo $(< "/run/secrets/$i"))";
    else
        export "${i}_PW=$i";
    fi
done

export K3D_DB_PW=${K3D_DB_PW-k3d}
export KONG_DB_PW=${KONG_DB_PW-kong}
export HARBOR_DB_PW=${HARBOR_DB_PW-harbor}

info() {
	# send all of our output to stderr
	exec 1>&2
	# if arguments are given, redirect them to stdin
	# this allows the funtion to be invoked with a string argument, or with stdin, e.g. via <<-EOF
	(($#)) && exec <<<"$@"
	[ -z "$NO_COLOR" ] && echo -n -e "\033[0;34m" # bold; yellow
	echo -n "     > "
	[ -z "$NO_COLOR" ] && echo -n -e "\033[0m" # reset style
	# this will be fed from stdin
	indent no_first_line_indent
}

status() {
	# send all of our output to stderr
	exec 1>&2
	# if arguments are given, redirect them to stdin
	# this allows the funtion to be invoked with a string argument, or with stdin, e.g. via <<-EOF
	(($#)) && exec <<<"$@"
	echo -n "-----> "
	# this will be fed from stdin
	cat
}

indent() {
	# if any value (e.g. a non-empty string, or true, or false) is given for the first argument, this will act as a flag indicating we shouldn't indent the first line; we use :+ to tell SED accordingly if that parameter is set, otherwise null string for no range selector prefix (it selects from line 2 onwards and then every 1st line, meaning all lines)
	# if the first argument is an empty string, it's the same as no argument (useful if a second argument is passed)
	# the second argument is the prefix to use for indenting; defaults to seven space characters, but can be set to e.g. " !     " to decorate each line of an error message
	local c="${1:+"2,999"} s/^/${2-"       "}/"
	case $(uname) in
	Darwin) sed -l "$c" ;; # mac/bsd sed: -l buffers on line boundaries
	*) sed -u "$c" ;;      # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
	esac
}

error() {
    # send all of our output to stderr
	exec 1>&2
	# if arguments are given, redirect them to stdin
	# this allows the funtion to be invoked with a string argument, or with stdin, e.g. via <<-EOF
	(($#)) && exec <<<"$@"
	[ -z "$NO_COLOR" ] && echo -e "\033[1;31m" # bold; red
	echo -n " !     ERROR: "
	# this will be fed from stdin
	indent no_first_line_indent " !     "
	[ -z "$NO_COLOR" ] && echo -e "\033[0m" # reset style
	exit 1
}

[ -z "${POSTGRESQL_PASSWORD}" ] && \
    error <<-EOF
        Unknown db password!

		Set database password via POSTGRESQL_PASSWORD.
	EOF

err_trap() {
	error <<-EOF
		An unknown internal error occurred.
		Stack trace follows for debugging purposes:
		$(
			local frame=0
			while caller $frame; do
				((frame++))
			done
		)
	EOF
}

# catching any errors after this line
trap 'err_trap' ERR

sql_exec() {
    PGPASSWORD=${POSTGRESQL_PASSWORD}
	psql -U ${POSTGRESQL_USERNAME} -c "$1"
}

status "Create user '${K3D_DB}' and database."
sql_exec "CREATE DATABASE ${K3D_DB}" | indent
sql_exec "CREATE USER ${K3D_DB} WITH ENCRYPTED PASSWORD '${K3D_DB_PW}';" | indent
sql_exec "GRANT ALL PRIVILEGES ON DATABASE ${K3D_DB} TO ${K3D_DB};" | indent
info "Done"

status "Create user '${KONG_DB}' and database."
sql_exec "CREATE DATABASE ${KONG_DB}" | indent
sql_exec "CREATE USER ${KONG_DB} WITH ENCRYPTED PASSWORD '${KONG_DB_PW}';" | indent
sql_exec "GRANT ALL PRIVILEGES ON DATABASE ${KONG_DB} TO ${KONG_DB};" | indent
info "Done"

status "Create user '${HARBOR_DB}' and database."
sql_exec "CREATE DATABASE ${HARBOR_DB}" | indent
sql_exec "CREATE USER ${HARBOR_DB} WITH ENCRYPTED PASSWORD '${HARBOR_DB_PW}';" | indent
sql_exec "GRANT ALL PRIVILEGES ON DATABASE ${HARBOR_DB} TO ${HARBOR_DB};" | indent
info "Done"
