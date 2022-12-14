#!/bin/bash
CERT_DIR=../certificates
ENABLED_DIR=../enabled

# [ -f "$ENABLED_DIR/ssl.conf" ] && echo -e "Error Script: $ENABLED_DIR/ssl.conf already exist!" && exit 0
# RootCA
./createRootCA.sh && echo RootCA CREATED
# localhost
./createLocalhost.sh localhost && echo "localhost.(crt|key|csr) CREATED"

OUTPUT=`cat <<'EOF'
server {
	server_name asaid-new.us.to 207.148.65.82;
	return 301 https://$host$request_uri;
}

server {
    include /nginx/snippets/ssl-domain.conf;
	server_name asaid-new.us.to 207.148.65.82;

	index index.html index.php;
    root /vhosts/ssl/httpdocs;
	location / {
		try_files $uri $uri/ /index.php$is_args$args;
	}

	include /nginx/snippets/php-fpm-default.conf;
}

# SUBDOMAINS
server {
	server_name ~^((?<subdomain>.*)\.)asaid-new(\.us\.to)?$;
	return 301 https://$host$request_uri;
}

server {
	include /nginx/snippets/ssl-domain.conf;
	server_name ~^((?<subdomain>.*)\.)asaid-new(\.us\.to)?$;

	index index.html index.php;
	root /vhosts/ssl/subdomains/${subdomain}/httpdocs;
	location / {
		try_files $uri $uri/ /index.php$is_args$args;
	}

	include /nginx/snippets/php-fpm-default.conf;
}
EOF
`
# OUTPUT: EOF

echo -e "$OUTPUT" > $ENABLED_DIR/ssl.conf
echo DONE.