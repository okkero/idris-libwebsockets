||| Functions that manipulate the libwebsockets context
module Context

import CFFI

%access export

%include C "lws.h"

string_to_c : String -> IO Ptr
string_to_c str = foreign FFI_C "string_to_c" (String -> IO Ptr) str

||| Format of the server's connection information
|||
||| Fields are:
||| Port - to listen on... you can use CONTEXT_PORT_NO_LISTEN to suppress listening on any port, that's what you want if you are not running a websocket server at all but just using it as a client
||| interface - String - to bind (null to bind the listen socket to all interfaces, or the interface name, eg, "eth2"
||| protocols -  Array of structures listing supported protocols and a protocol- specific callback for each one.  The list is ended with an entry that has a NULL callback pointer.
||| extensions - Null or array of lws_extension structs listing the extensions this context supports.  If you configured with --without-extensions, you should give Null here.
||| token-limits - Null or struct lws_token_limits pointer which is initialized with a token length limit for each possible WSI_TOKEN_***
||| ssl_private_key_password - String - can pass Null
||| ssl_cert_filepath - String - If libwebsockets was compiled to use ssl, and you want	to listen using SSL, set to the filepath to fetch the server cert from, otherwise Null for unencrypted
||| ssl_private_key_filepath - String - filepath to private key if wanting SSL mode; if this is set to Null but sll_cert_filepath is set, the OPENSSL_CONTEXT_REQUIRES_PRIVATE_KEY callback is called to allow setting of the private key directly via openSSL library calls
||| ssl_ca_filepath - String - CA certificate filepath or Nulll
||| ssl_cipher_list - String - List of valid ciphers to use (eg, "RC4-MD5:RC4-SHA:AES128-SHA:AES256-SHA:HIGH:!DSS:!aNULL" or you can leave it as Null to get "DEFAULT"
||| http_proxy_address - String - If non-Null, attempts to proxy via the given address. If proxy auth is required, use format "username:password@server:port"
||| http_proxy_port - If http_proxy_address was non-Null, uses this port at the address
||| gid - group id to change to after setting listen socket, or -1.
||| uid - user id to change to after setting listen socket, or -1.
||| options - 0, or LWS_SERVER_OPTION_... bitfields
||| user - optional user pointer that can be recovered via the context pointer using lws_context_user
||| ka_time - 0 for no keepalive, otherwise apply this keepalive timeout to all libwebsocket sockets, client or server
||| ka_probes - if ka_time was nonzero, after the timeout expires how many times to try to get a response from the peer before giving up and killing the connection
||| ka_interval if ka_time was nonzero, how long to wait before each ka_probes attempt
||| provided_client_ssl_ctx - If non-null, swap out libwebsockets ssl implementation for the one provided by provided_ssl_ctx. Libwebsockets no longer is responsible for freeing the context if this option is selected.
||| max_http_header_data - The max amount of header payload that can be handled in an http request (unrecognized header payload is dropped)
||| max_http_header_pool - The max number of connections with http headers that can be processed simultaneously (the corresponding memory is allocated for the lifetime of the context).  If the pool is busy new incoming connections must wait for accept until one becomes free.
||| count_threads - how many contexts to create in an array, 0 = 1
||| fd_limit_per_thread - nonzero means restrict each service thread to this any fds, 0 means the default which is divide the process fd limit by the number of threads.
||| timeout_secs - various processes involving network roundtrips in the library are protected from hanging forever by timeouts.  If nonzero, this member lets you set the timeout used in seconds. Otherwise a default timeout is used.
||| 8 unused pointers follow
private
connection_information_struct : Composite
connection_information_struct = STRUCT [I32, PTR, PTR, PTR, PTR, PTR, PTR, PTR, PTR, PTR, PTR, I32, I32, I32, I32, PTR, I32, I32, I32, PTR, I16, I16, I32, I32, I32, PTR, PTR, PTR, PTR, PTR, PTR, PTR, PTR]

||| Access to the server's connection information
connection_information : IO Ptr
connection_information = foreign FFI_C "&connection_information" (IO Ptr)

-- Field indices into connection_information_struct
port_field : Ptr -> CPtr
port_field info = (connection_information_struct#0) info

interface_field : Ptr -> CPtr
interface_field info = (connection_information_struct#1) info

extensions_field : Ptr -> CPtr
extensions_field info = (connection_information_struct#3) info

ssl_cert_field : Ptr -> CPtr
ssl_cert_field info = (connection_information_struct#5) info

ssl_key_field : Ptr -> CPtr
ssl_key_field info = (connection_information_struct#6) info

gid_field : Ptr -> CPtr
gid_field info = (connection_information_struct#11) info

uid_field : Ptr -> CPtr
uid_field info = (connection_information_struct#12) info

options_field : Ptr -> CPtr
options_field info = (connection_information_struct#13) info

max_http_header_pool_field : Ptr -> CPtr
max_http_header_pool_field info = (connection_information_struct#20) info

||| Zero the connection information
|||
||| Call prior to create_context, or any calls to connection_information
clear_connection_information : IO ()
clear_connection_information = foreign FFI_C "clear_connection_information" (IO ())

||| Set the maximum size of the HTTP header pool
|||
||| @info - Result of call to connection_information
||| @size - size to be set
set_max_http_header_pool : (info : Ptr) -> (size : Bits16) -> IO ()
set_max_http_header_pool info size = do
  poke I16 (max_http_header_pool_field info) size

||| Set the port on which to listen
|||
||| @info - Result of call to connection_information
||| @port - The port to listen on.
set_port : (info : Ptr) -> (port : Bits32) -> IO ()
set_port info port = do
  poke I32 (port_field info) port

||| Set the group id under which to run
|||
||| @info - Result of call to connection_information
||| @gid - The gid to listen on.
set_gid : (info : Ptr) -> (gid : Bits32) -> IO ()
set_gid info gid = do
  poke I32 (gid_field info) gid

||| Set the user id under which to run
|||
||| @info - Result of call to connection_information
||| @uid - The uid to listen on.
set_uid : (info : Ptr) -> (uid : Bits32) -> IO ()
set_uid info uid = do
  poke I32 (uid_field info) uid
 
||| Set the SSL certificate file-path
|||
||| @info - Result of call to connection_information
||| @cert - file-path to the certicate
set_ssl_certificate_path : (info : Ptr) -> (cert : String) -> IO ()
set_ssl_certificate_path info cert = do
  str <- string_to_c cert
  poke PTR (ssl_cert_field info) str
 
||| Set the SSL private-key file-path
|||
||| @info - Result of call to connection_information
||| @key - file path to the key
set_ssl_key_path : (info : Ptr) -> (key : String) -> IO ()
set_ssl_key_path info key = do
  str <- string_to_c key
  poke PTR (ssl_key_field info) str

||| Set the only interface on which to listen
|||
||| @info - Result of call to connection_information
||| @iface - The sole interface to listen on.
set_interface : (info : Ptr) -> (iface : String) -> IO ()
set_interface info iface = do
  str <- string_to_c iface
  poke PTR (interface_field info) str

||| Set extensions in use
|||
||| @info - Result of call to connection_information
||| @exts - The extensions to use
set_extensions : (info : Ptr) -> (exts : Ptr) -> IO ()
set_extensions info exts = do
  poke PTR (extensions_field info) exts

-- server options

LWS_SERVER_OPTION_REQUIRE_VALID_OPENSSL_CLIENT_CERT : Bits32
LWS_SERVER_OPTION_REQUIRE_VALID_OPENSSL_CLIENT_CERT = 4098

LWS_SERVER_OPTION_SKIP_SERVER_CANONICAL_NAME : Bits32
LWS_SERVER_OPTION_SKIP_SERVER_CANONICAL_NAME = 4

LWS_SERVER_OPTION_ALLOW_NON_SSL_ON_SSL_PORT : Bits32
LWS_SERVER_OPTION_ALLOW_NON_SSL_ON_SSL_PORT = 4104

LWS_SERVER_OPTION_LIBEV : Bits32
LWS_SERVER_OPTION_LIBEV = 16

LWS_SERVER_OPTION_DISABLE_IPV6 : Bits32
LWS_SERVER_OPTION_DISABLE_IPV6 = 32

LWS_SERVER_OPTION_DISABLE_OS_CA_CERTS : Bits32
LWS_SERVER_OPTION_DISABLE_OS_CA_CERTS = 64

LWS_SERVER_OPTION_PEER_CERT_NOT_REQUIRED : Bits32
LWS_SERVER_OPTION_PEER_CERT_NOT_REQUIRED = 128

LWS_SERVER_OPTION_VALIDATE_UTF8 : Bits32
LWS_SERVER_OPTION_VALIDATE_UTF8 = 256

LWS_SERVER_OPTION_SSL_ECDH : Bits32
LWS_SERVER_OPTION_SSL_ECDH = 4608

LWS_SERVER_OPTION_LIBUV: Bits32
LWS_SERVER_OPTION_LIBUV = 1024

LWS_SERVER_OPTION_REDIRECT_HTTP_TO_HTTPS : Bits32
LWS_SERVER_OPTION_REDIRECT_HTTP_TO_HTTPS = 6152

LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT : Bits32
LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT = 4096

LWS_SERVER_OPTION_EXPLICIT_VHOST : Bits32
LWS_SERVER_OPTION_EXPLICIT_VHOST = 8192

LWS_SERVER_OPTION_UNIX_SOC : Bits32
LWS_SERVER_OPTION_UNIX_SOC = 16384

LWS_SERVER_OPTION_STS : Bits32
LWS_SERVER_OPTION_STS = 32768

--LWS_SERVER_OPTION_SKIP_SERVER_CANONICAL_NAME
||| Set the connection options
|||
||| @info    - Result of call to connection_information
||| @options - Options to be set
set_options : (info : Ptr) -> (options : Bits32) -> IO ()
set_options info options = do
  poke I32 (port_field info) options

||| Create the websocket handler
||| This function creates the listening socket (if serving) and takes care of all initialization in one step.
||| After initialization, it returns a struct lws_context * that represents this server. After calling, user code needs to take care of calling lws_service with the context pointer to get the server's sockets serviced. This must be done in the same process context as the initialization call.
||| The protocol callback functions are called for a handful of events including http requests coming in, websocket connections becoming established, and data arriving; it's also called periodically to allow async transmission.
||| HTTP requests are sent always to the FIRST protocol in protocol, since at that time websocket protocol has not been negotiated. Other protocols after the first one never see any HTTP callack activity.
||| The server created is a simple http server by default; part of the websocket standard is upgrading this http connection to a websocket one.
||| This allows the same server to provide files like scripts and favicon / images or whatever over http and dynamic data over websockets all in one place; they're all handled in the user callback.
|||
||| @context_creation_info - parameters needed to create the context
create_context : (context_creation_info : Ptr) -> IO Ptr
create_context info = foreign FFI_C "lws_create_context" (Ptr -> IO Ptr) info
