export SERVICE=vault
export NAMESPACE=vault
export SECRET_NAME=vault-tls
export CSR_NAME=vault
export BASENAME=tls
export TMPDIR=/opt/vault/tls

# Create private key
openssl genrsa -out ${TMPDIR}/${BASENAME}.key  2048 -days 3651

# Create a file ${TMPDIR}/${NAMESPACE}-csr.conf with the following contents
cat <<EOF >${TMPDIR}/${BASENAME}-csr.conf
[ req ]
default_bits = 2048
prompt = no
encrypt_key = yes
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
[ dn ]
C = BR
ST = Minas Gerais
L = Belo Horizonte
O = CI&T
emailAddress = felipefr@ciandt.com
CN = ${SERVICE}.${NAMESPACE}.local
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${SERVICE}
DNS.2 = ${SERVICE}.${NAMESPACE}
DNS.3 = ${SERVICE}.${NAMESPACE}.svc
DNS.4 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
IP.1  = 127.0.0.1
EOF

# Create a CSR
openssl req -config ${TMPDIR}/${BASENAME}-csr.conf -new -key ${TMPDIR}/${BASENAME}.key -subj "/CN=${SERVICE}.${NAMESPACE}.svc" -out ${TMPDIR}/${BASENAME}.csr -days 3651
