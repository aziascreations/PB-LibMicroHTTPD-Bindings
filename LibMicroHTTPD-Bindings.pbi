;{- Code Header
; ==- Basic Info -================================
;         Name: LibMicroHTTPD-Bindings.pbi
;      Version: 0.0.1
;       Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version:
;    * PureBasic 6.0 LTS
;    * PureBasic 6.0 LTS - C Backend
;  Operating systems tested:
;    * Windows
;      * x64 - 10 21H2
;    * Linux
;      * ARM64 - Ubuntu container (linuxserver/webtop:ubuntu-xfce)
;  libmicrohttpd versions:
;    * 0.9.75  (All architectures)
; 
; ==- Requirements -==============================
;  libmicrohttpd - v0.9.75+ - LGPL 2.1
;    * https://www.gnu.org/software/libmicrohttpd/
;  PB-CTypes - v1.0.0+ - Unlicense
;    * https://github.com/aziascreations/PB-CTypes
; 
; ==- Links & License -===========================
;  License: 
;  GitHub: https://github.com/aziascreations/PB-LibMicroHTTPD-Bindings
; 
; ==- Notes -=====================================
;  * Requires "Universal C Runtime (UCRT)" on Windows !  (Vista SP2 or newer)
;  * Support for PureBasic 5.xx can be achieved by removing checks for ARM64 and ARM32 libraries.
;}


;- Compiler Directives
EnableExplicit


;- Includes
XIncludeFile "../PB-CTypes/PB-CTypes.pbi"  ; Used to get function signatures & types closer to the C header.


;- Library Path Detection
CompilerIf Not Defined(LIBMICROHTTPD_LIBRARY_PATH$, #PB_Constant)
	; Detecting the library's path in case "#LIBMICROHTTPD_LIBRARY_PATH$" is not already defined.
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Linux
		; Linux
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
			; Linux - x64
			CompilerError = "X64 Linux isn't implemented yet !"
		CompilerElseIf #PB_Compiler_Processor = #PB_Processor_Arm64
			; Linux - ARM64
			CompilerIf Defined(LIBMICROHTTPD_LIBRARY_PATH_LINUX_ARM64, #PB_Constant)
				#LIBMICROHTTPD_LIBRARY_PATH$ = #LIBMICROHTTPD_LIBRARY_PATH_LINUX_ARM64
			CompilerElse
				; See: https://packages.ubuntu.com/jammy/arm64/libmicrohttpd-dev/filelist
				#LIBMICROHTTPD_LIBRARY_PATH$ = "/usr/lib/aarch64-linux-gnu/libmicrohttpd.so"
			CompilerEndIf
		CompilerElse
			; Other Linux
			CompilerError "The x86 and ARM32 architectures are not supported for Linux !"
		CompilerEndIf
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
		; Any Windows version.
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
			; Windows - x64
			CompilerIf Defined(LIBMICROHTTPD_LIBRARY_PATH_WINDOWS_X64, #PB_Constant)
				#LIBMICROHTTPD_LIBRARY_PATH$ = #LIBMICROHTTPD_LIBRARY_PATH_WINDOWS_X64
			CompilerElse
				; Attempting to use the default search paths.
				#LIBMICROHTTPD_LIBRARY_PATH$ = "libmicrohttpd-dll.lib"
				CompilerWarning "Using the default library path for libmicrohttpd on x64 Windows !"
			CompilerEndIf
		CompilerElse
			; Other Windows
			CompilerError "The x86 and ARM architectures are not supported for Windows !"
		CompilerEndIf
		
	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
		; Any MacOS version.
		CompilerError "MacOS isn't supported !"
		
	CompilerElse
		; Any other, just to be safe.
		CompilerError "The operating system you are using isn't supported !"
	CompilerEndIf
CompilerEndIf


;- Type Definition Macros
Macro MHD_FIXED_ENUM : l : EndMacro
Macro MHD_FIXED_FLAGS_ENUM : l : EndMacro

Macro EnumType_Result : MHD_FIXED_ENUM : EndMacro
Macro EnumType_FLAG : l : EndMacro  ; Does not appear to use the common types !
Macro EnumType_OPTION : MHD_FIXED_ENUM : EndMacro
Macro EnumType_DisableSanityCheck : MHD_FIXED_FLAGS_ENUM : EndMacro
Macro EnumType_ValueKind : MHD_FIXED_ENUM : EndMacro
Macro EnumType_RequestTerminationCode : MHD_FIXED_ENUM : EndMacro
Macro EnumType_ConnectionNotificationCode : MHD_FIXED_ENUM : EndMacro
Macro EnumType_ConnectionInfoType : MHD_FIXED_ENUM : EndMacro
Macro EnumType_DaemonInfoType : MHD_FIXED_ENUM : EndMacro

Macro EnumType_ResponseMemoryMode : MHD_FIXED_ENUM : EndMacro

;- Structures
;{

;-> Virtual Structures  (Unused)
; These structure are unused/undeclared to avoid issued with "SizeOf()".
; They are define in ".c" files are aren't meant to be directly manipulated !

; Handle for the daemon (listening on a socket for HTTP traffic).
; struct MHD_Daemon;

; Handle for a connection / HTTP request.
; With HTTP/1.1, multiple requests can be run over the same connection.
; However, MHD will only show one request per TCP connection to the client at any given time.
; struct MHD_Connection;

; Handle for a response.
; struct MHD_Response;

; Handle for POST processing.
; struct MHD_PostProcessor;


;-> MHD_OptionItem

; Entry in an #MHD_OPTION_ARRAY.
Structure MHD_OptionItem Align #PB_Structure_AlignC
	; Which option is being given.  Use #MHD_OPTION_END
	;  to terminate the array.
	option.EnumType_OPTION
	;enum MHD_OPTION option;
	
	; Option value (for integer arguments, and for options requiring
	;  two pointer arguments); should be 0 for options that take no
	;  arguments or only a single pointer argument.
	*value  ;.i
			;intptr_t value;
	
	; Pointer option value (use NULL for options taking no arguments
	;  or only an integer option).
	*ptr_value
	;void; ptr_value;
EndStructure


;-> MHD_ConnectionInfo  (Union)

; Information about a connection.
Structure MHD_ConnectionInfo Align #PB_Structure_AlignC
	StructureUnion
		; Cipher algorithm used, of type "enum gnutls_cipher_algorithm".
		cipher_algorithm.int
		;int /* enum gnutls_cipher_algorithm */ cipher_algorithm;
		
		; Protocol used, of type "enum gnutls_protocol".
		protocol.int
		;int /* enum gnutls_protocol */ protocol;
		
		; The suspended status of a connection.
		suspended.int
		;int /* MHD_YES Or MHD_NO */ suspended;
		
		; Amount of second that connection could spend in idle state
		; before automatically disconnected.
		; Zero for no timeout (unlimited idle time).
		connection_timeout.uint
		;unsigned int connection_timeout;
		
		; HTTP status queued with the response, for #MHD_CONNECTION_INFO_HTTP_STATUS.
		http_status.uint
		;unsigned int http_status;
		
		; Connect socket
		*connect_fd  ;FIXME: The type !
					 ;MHD_socket connect_fd;
		
		; Size of the client's HTTP header.
		header_size.size_t
		;size_t header_size;
		
		; GNUtls session handle, of type "gnutls_session_t".
		*tls_session
		;void * /* gnutls_session_t */ tls_session;
		
		; GNUtls client certificate handle, of type "gnutls_x509_crt_t".
		*client_cert
		;void * /* gnutls_x509_crt_t */ client_cert;
		
		; Address information for the client.
		*client_addr.SOCKADDR
		;struct sockaddr *client_addr;
		
		; Which daemon manages this connection (useful in case there are many
		; daemons running).
		*daemon
		;struct MHD_Daemon *daemon;
		
		; Socket-specific client context.  Points to the same address as
		; the "socket_context" of the #MHD_NotifyConnectionCallback.
		*socket_context
		;void *socket_context;
	EndStructureUnion
EndStructure


;-> MHD_IoVec

; I/O vector type. Provided for use with #MHD_create_response_from_iovec().
; Available since #MHD_VERSION 0x00097204
Structure MHD_IoVec Align #PB_Structure_AlignC
	; The pointer to the memory region for I/O.
	*iov_base
	;const void *iov_base;
	
	; The size in bytes of the memory region for I/O.
	iov_len.size_t
	;size_t iov_len;
EndStructure

;}


;- Constants
;{

;-> Commons
;{
; Current version of the library.
; Version number components are coded as Simple Binary-Coded Decimal (also called Natural BCD or BCD 8421).
; While they are hexadecimal numbers, they are parsed as decimal numbers.
; Example: 0x01093001 = 1.9.30-1.
#MHD_VERSION = $00097500  ; 00.09.75-00 or 0.9.75

; MHD digest auth internal code for an invalid nonce.
#MHD_INVALID_NONCE = -1

; Length of the binary output of the MD5 hash function.
#MHD_MD5_DIGEST_SIZE = 16

;}


;-> HTTP Response Codes
;{

;-> > 1xx Informational

; 100 - "Continue"             RFC7231, Section 6.2.1
#MHD_HTTP_CONTINUE = 100

; 101 - "Switching Protocols"  RFC7231, Section 6.2.2
#MHD_HTTP_SWITCHING_PROTOCOLS = 101

; 102 - "Processing"           RFC2518
#MHD_HTTP_PROCESSING = 102

; 103 - "Early Hints"          RFC8297
#MHD_HTTP_EARLY_HINTS = 103


;-> > 2xx Successful

; 200 - "OK"                RFC7231, Section 6.3.1
#MHD_HTTP_OK = 200

; 201 - "Created"           RFC7231, Section 6.3.2
#MHD_HTTP_CREATED = 201

; 202 - "Accepted"          RFC7231, Section 6.3.3
#MHD_HTTP_ACCEPTED = 202

; 203 - "Non-Authoritative Information"  RFC7231, Section 6.3.4
#MHD_HTTP_NON_AUTHORITATIVE_INFORMATION = 203

; 204 - "No Content"        RFC7231, Section 6.3.5
#MHD_HTTP_NO_CONTENT = 204

; 205 - "Reset Content"     RFC7231, Section 6.3.6
#MHD_HTTP_RESET_CONTENT = 205

; 206 - "Partial Content"   RFC7233, Section 4.1
#MHD_HTTP_PARTIAL_CONTENT = 206

; 207 - "Multi-Status"      RFC4918
#MHD_HTTP_MULTI_STATUS = 207

; 208 - "Already Reported"  RFC5842
#MHD_HTTP_ALREADY_REPORTED = 208

; 226 - "IM Used"           RFC3229
#MHD_HTTP_IM_USED = 226


;-> > 3xx Redirection

; 300 - "Multiple Choices"    RFC7231, Section 6.4.1
#MHD_HTTP_MULTIPLE_CHOICES = 300

; 301 - "Moved Permanently"   RFC7231, Section 6.4.2
#MHD_HTTP_MOVED_PERMANENTLY = 301

; 302 - "Found"               RFC7231, Section 6.4.3
#MHD_HTTP_FOUND = 302

; 303 - "See Other"           RFC7231, Section 6.4.4
#MHD_HTTP_SEE_OTHER = 303

; 304 - "Not Modified"        RFC7232, Section 4.1
#MHD_HTTP_NOT_MODIFIED = 304

; 305 - "Use Proxy"           RFC7231, Section 6.4.5
#MHD_HTTP_USE_PROXY = 305

; 306 - "Switch Proxy"        Not used! RFC7231, Section 6.4.6
#MHD_HTTP_SWITCH_PROXY = 306

; 307 - "Temporary Redirect"  RFC7231, Section 6.4.7
#MHD_HTTP_TEMPORARY_REDIRECT = 307

; 308 - "Permanent Redirect"  RFC7538
#MHD_HTTP_PERMANENT_REDIRECT = 308


;-> > 4xx Client Error

; 400 - "Bad Request"         RFC7231, Section 6.5.1
#MHD_HTTP_BAD_REQUEST = 400

; 401 - "Unauthorized"        RFC7235, Section 3.1
#MHD_HTTP_UNAUTHORIZED = 401

; 402 - "Payment Required"    RFC7231, Section 6.5.2
#MHD_HTTP_PAYMENT_REQUIRED = 402

; 403 - "Forbidden"           RFC7231, Section 6.5.3
#MHD_HTTP_FORBIDDEN = 403

; 404 - "Not Found"           RFC7231, Section 6.5.4
#MHD_HTTP_NOT_FOUND = 404

; 405 - "Method Not Allowed"  RFC7231, Section 6.5.5
#MHD_HTTP_METHOD_NOT_ALLOWED = 405

; 406 - "Not Acceptable"      RFC7231, Section 6.5.6
#MHD_HTTP_NOT_ACCEPTABLE = 406

; 407 - "Proxy Authentication Required"  RFC7235, Section 3.2
#MHD_HTTP_PROXY_AUTHENTICATION_REQUIRED = 407

; 408 - "Request Timeout"      RFC7231, Section 6.5.7
#MHD_HTTP_REQUEST_TIMEOUT = 408

; 409 - "Conflict"             RFC7231, Section 6.5.8
#MHD_HTTP_CONFLICT = 409

; 410 - "Gone"                 RFC7231, Section 6.5.9
#MHD_HTTP_GONE = 410

; 411 - "Length Required"      RFC7231, Section 6.5.10
#MHD_HTTP_LENGTH_REQUIRED = 411

; 412 - "Precondition Failed"  RFC7232, Section 4.2; RFC8144, Section 3.2
#MHD_HTTP_PRECONDITION_FAILED = 412

; 413 - "Payload Too Large"    RFC7231, Section 6.5.11
#MHD_HTTP_PAYLOAD_TOO_LARGE = 413

; 414 - "URI Too Long"         RFC7231, Section 6.5.12
#MHD_HTTP_URI_TOO_LONG = 414

; 415 - "Unsupported Media Type"  RFC7231, Section 6.5.13; RFC7694, Section 3
#MHD_HTTP_UNSUPPORTED_MEDIA_TYPE = 415

; 416 - "Range Not Satisfiable"   RFC7233, Section 4.4
#MHD_HTTP_RANGE_NOT_SATISFIABLE = 416

; 417 - "Expectation Failed"      RFC7231, Section 6.5.14
#MHD_HTTP_EXPECTATION_FAILED = 417

; 421 - "Misdirected Request"     RFC7540, Section 9.1.2
#MHD_HTTP_MISDIRECTED_REQUEST = 421

; 422 - "Unprocessable Entity"    RFC4918
#MHD_HTTP_UNPROCESSABLE_ENTITY = 422

; 423 - "Locked"                  RFC4918
#MHD_HTTP_LOCKED = 423

; 424 - "Failed Dependency"       RFC4918
#MHD_HTTP_FAILED_DEPENDENCY = 424

; 425 - "Too Early"               RFC8470
#MHD_HTTP_TOO_EARLY = 425

; 426 - "Upgrade Required"        RFC7231, Section 6.5.15
#MHD_HTTP_UPGRADE_REQUIRED = 426

; 428 - "Precondition Required"   RFC6585
#MHD_HTTP_PRECONDITION_REQUIRED = 428

; 429 - "Too Many Requests"       RFC6585
#MHD_HTTP_TOO_MANY_REQUESTS = 429

; 431 - "Request Header Fields Too Large"  RFC6585
#MHD_HTTP_REQUEST_HEADER_FIELDS_TOO_LARGE = 431

; 451 - "Unavailable For Legal Reasons"    RFC7725
#MHD_HTTP_UNAVAILABLE_FOR_LEGAL_REASONS = 451


;-> > 5xx Server Error

; 500 - "Internal Server Error"       RFC7231, Section 6.6.1
#MHD_HTTP_INTERNAL_SERVER_ERROR = 500

; 501 - "Not Implemented"             RFC7231, Section 6.6.2
#MHD_HTTP_NOT_IMPLEMENTED = 501

; 502 - "Bad Gateway"                 RFC7231, Section 6.6.3
#MHD_HTTP_BAD_GATEWAY = 502

; 503 - "Service Unavailable"         RFC7231, Section 6.6.4
#MHD_HTTP_SERVICE_UNAVAILABLE = 503

; 504 - "Gateway Timeout"             RFC7231, Section 6.6.5
#MHD_HTTP_GATEWAY_TIMEOUT = 504

; 505 - "HTTP Version Not Supported"  RFC7231, Section 6.6.6
#MHD_HTTP_HTTP_VERSION_NOT_SUPPORTED = 505

; 506 - "Variant Also Negotiates"     RFC2295
#MHD_HTTP_VARIANT_ALSO_NEGOTIATES = 506

; 507 - "Insufficient Storage"        RFC4918
#MHD_HTTP_INSUFFICIENT_STORAGE = 507

; 508 - "Loop Detected"               RFC5842
#MHD_HTTP_LOOP_DETECTED = 508

; 510 - "Not Extended"                RFC2774
#MHD_HTTP_NOT_EXTENDED = 510

; 511 - "Network Authentication Required"  RFC6585
#MHD_HTTP_NETWORK_AUTHENTICATION_REQUIRED = 511


;-> > Not registered / standard

; 449 - "Reply With"                            MS IIS extension
#MHD_HTTP_RETRY_WITH = 449

; 450 - "Blocked by Windows Parental Controls"  MS extension
#MHD_HTTP_BLOCKED_BY_WINDOWS_PARENTAL_CONTROLS = 450

; 509 - "Bandwidth Limit Exceeded"              Apache extension
#MHD_HTTP_BANDWIDTH_LIMIT_EXCEEDED = 509


;-> > Missing in "libmicrohttpd.h "

; 418 - "I'm a teapot"            RFC2324, Section-2.3.2
; Not defined in libmicrohttpd, but standard and recognized, even if it is as a joke.
#MHD_HTTP_I_AM_A_TEAPOT = 418

;}


;-> HTTP Headers

; Main HTTP headers.;
; Standard.      RFC7231, Section 5.3.2;
#MHD_HTTP_HEADER_ACCEPT = "Accept"
; Standard.      RFC7231, Section 5.3.3;
#MHD_HTTP_HEADER_ACCEPT_CHARSET = "Accept-Charset"
; Standard.      RFC7231, Section 5.3.4; RFC7694, Section 3;
#MHD_HTTP_HEADER_ACCEPT_ENCODING = "Accept-Encoding"
; Standard.      RFC7231, Section 5.3.5;
#MHD_HTTP_HEADER_ACCEPT_LANGUAGE = "Accept-Language"
; Standard.      RFC7233, Section 2.3;
#MHD_HTTP_HEADER_ACCEPT_RANGES = "Accept-Ranges"
; Standard.      RFC7234, Section 5.1;
#MHD_HTTP_HEADER_AGE = "Age"
; Standard.      RFC7231, Section 7.4.1;
#MHD_HTTP_HEADER_ALLOW = "Allow"
; Standard.      RFC7235, Section 4.2;
#MHD_HTTP_HEADER_AUTHORIZATION = "Authorization"
; Standard.      RFC7234, Section 5.2;
#MHD_HTTP_HEADER_CACHE_CONTROL = "Cache-Control"
; Reserved.      RFC7230, Section 8.1;
#MHD_HTTP_HEADER_CLOSE = "Close"
; Standard.      RFC7230, Section 6.1;
#MHD_HTTP_HEADER_CONNECTION = "Connection"
; Standard.      RFC7231, Section 3.1.2.2;
#MHD_HTTP_HEADER_CONTENT_ENCODING = "Content-Encoding"
; Standard.      RFC7231, Section 3.1.3.2;
#MHD_HTTP_HEADER_CONTENT_LANGUAGE = "Content-Language"
; Standard.      RFC7230, Section 3.3.2;
#MHD_HTTP_HEADER_CONTENT_LENGTH = "Content-Length"
; Standard.      RFC7231, Section 3.1.4.2;
#MHD_HTTP_HEADER_CONTENT_LOCATION = "Content-Location"
; Standard.      RFC7233, Section 4.2;
#MHD_HTTP_HEADER_CONTENT_RANGE = "Content-Range"
; Standard.      RFC7231, Section 3.1.1.5;
#MHD_HTTP_HEADER_CONTENT_TYPE = "Content-Type"
; Standard.      RFC7231, Section 7.1.1.2;
#MHD_HTTP_HEADER_DATE = "Date"
; Standard.      RFC7232, Section 2.3;
#MHD_HTTP_HEADER_ETAG = "ETag"
; Standard.      RFC7231, Section 5.1.1;
#MHD_HTTP_HEADER_EXPECT = "Expect"
; Standard.      RFC7234, Section 5.3;
#MHD_HTTP_HEADER_EXPIRES = "Expires"
; Standard.      RFC7231, Section 5.5.1;
#MHD_HTTP_HEADER_FROM = "From"
; Standard.      RFC7230, Section 5.4;
#MHD_HTTP_HEADER_HOST = "Host"
; Standard.      RFC7232, Section 3.1;
#MHD_HTTP_HEADER_IF_MATCH = "If-Match"
; Standard.      RFC7232, Section 3.3;
#MHD_HTTP_HEADER_IF_MODIFIED_SINCE = "If-Modified-Since"
; Standard.      RFC7232, Section 3.2;
#MHD_HTTP_HEADER_IF_NONE_MATCH = "If-None-Match"
; Standard.      RFC7233, Section 3.2;
#MHD_HTTP_HEADER_IF_RANGE = "If-Range"
; Standard.      RFC7232, Section 3.4;
#MHD_HTTP_HEADER_IF_UNMODIFIED_SINCE = "If-Unmodified-Since"
; Standard.      RFC7232, Section 2.2;
#MHD_HTTP_HEADER_LAST_MODIFIED = "Last-Modified"
; Standard.      RFC7231, Section 7.1.2;
#MHD_HTTP_HEADER_LOCATION = "Location"
; Standard.      RFC7231, Section 5.1.2;
#MHD_HTTP_HEADER_MAX_FORWARDS = "Max-Forwards"
; Standard.      RFC7231, Appendix A.1;
#MHD_HTTP_HEADER_MIME_VERSION = "MIME-Version"
; Standard.      RFC7234, Section 5.4;
#MHD_HTTP_HEADER_PRAGMA = "Pragma"
; Standard.      RFC7235, Section 4.3;
#MHD_HTTP_HEADER_PROXY_AUTHENTICATE = "Proxy-Authenticate"
; Standard.      RFC7235, Section 4.4;
#MHD_HTTP_HEADER_PROXY_AUTHORIZATION = "Proxy-Authorization"
; Standard.      RFC7233, Section 3.1;
#MHD_HTTP_HEADER_RANGE = "Range"
; Standard.      RFC7231, Section 5.5.2;
#MHD_HTTP_HEADER_REFERER = "Referer"
; Standard.      RFC7231, Section 7.1.3;
#MHD_HTTP_HEADER_RETRY_AFTER = "Retry-After"
; Standard.      RFC7231, Section 7.4.2;
#MHD_HTTP_HEADER_SERVER = "Server"
; Standard.      RFC7230, Section 4.3;
#MHD_HTTP_HEADER_TE = "TE"
; Standard.      RFC7230, Section 4.4;
#MHD_HTTP_HEADER_TRAILER = "Trailer"
; Standard.      RFC7230, Section 3.3.1;
#MHD_HTTP_HEADER_TRANSFER_ENCODING = "Transfer-Encoding"
; Standard.      RFC7230, Section 6.7;
#MHD_HTTP_HEADER_UPGRADE = "Upgrade"
; Standard.      RFC7231, Section 5.5.3;
#MHD_HTTP_HEADER_USER_AGENT = "User-Agent"
; Standard.      RFC7231, Section 7.1.4;
#MHD_HTTP_HEADER_VARY = "Vary"
; Standard.      RFC7230, Section 5.7.1;
#MHD_HTTP_HEADER_VIA = "Via"
; Standard.      RFC7235, Section 4.1;
#MHD_HTTP_HEADER_WWW_AUTHENTICATE = "WWW-Authenticate"
; Standard.      RFC7234, Section 5.5;
#MHD_HTTP_HEADER_WARNING = "Warning"


;-> Additional HTTP headers.
; No category.   RFC4229;
#MHD_HTTP_HEADER_A_IM = "A-IM"
; No category.   RFC4229;
#MHD_HTTP_HEADER_ACCEPT_ADDITIONS = "Accept-Additions"
; Informational. RFC7089;
#MHD_HTTP_HEADER_ACCEPT_DATETIME = "Accept-Datetime"
; No category.   RFC4229;
#MHD_HTTP_HEADER_ACCEPT_FEATURES = "Accept-Features"
; No category.   RFC5789;
#MHD_HTTP_HEADER_ACCEPT_PATCH = "Accept-Patch"
; Standard.      https://www.w3.org/TR/ldp/;
#MHD_HTTP_HEADER_ACCEPT_POST = "Accept-Post"
; Standard.      RFC7639, Section 2;
#MHD_HTTP_HEADER_ALPN = "ALPN"
; Standard.      RFC7838;
#MHD_HTTP_HEADER_ALT_SVC = "Alt-Svc"
; Standard.      RFC7838;
#MHD_HTTP_HEADER_ALT_USED = "Alt-Used"
; No category.   RFC4229;
#MHD_HTTP_HEADER_ALTERNATES = "Alternates"
; No category.   RFC4437;
#MHD_HTTP_HEADER_APPLY_TO_REDIRECT_REF = "Apply-To-Redirect-Ref"
; Experimental.  RFC8053, Section 4;
#MHD_HTTP_HEADER_AUTHENTICATION_CONTROL = "Authentication-Control"
; Standard.      RFC7615, Section 3;
#MHD_HTTP_HEADER_AUTHENTICATION_INFO = "Authentication-Info"
; No category.   RFC4229;
#MHD_HTTP_HEADER_C_EXT = "C-Ext"
; No category.   RFC4229;
#MHD_HTTP_HEADER_C_MAN = "C-Man"
; No category.   RFC4229;
#MHD_HTTP_HEADER_C_OPT = "C-Opt"
; No category.   RFC4229;
#MHD_HTTP_HEADER_C_PEP = "C-PEP"
; No category.   RFC4229;
#MHD_HTTP_HEADER_C_PEP_INFO = "C-PEP-Info"
; Standard.      RFC8607, Section 5.1;
#MHD_HTTP_HEADER_CAL_MANAGED_ID = "Cal-Managed-ID"
; Standard.      RFC7809, Section 7.1;
#MHD_HTTP_HEADER_CALDAV_TIMEZONES = "CalDAV-Timezones"
; Standard.      RFC8586;
#MHD_HTTP_HEADER_CDN_LOOP = "CDN-Loop"
; Obsoleted.     RFC2068; RFC2616;
#MHD_HTTP_HEADER_CONTENT_BASE = "Content-Base"
; Standard.      RFC6266;
#MHD_HTTP_HEADER_CONTENT_DISPOSITION = "Content-Disposition"
; No category.   RFC4229;
#MHD_HTTP_HEADER_CONTENT_ID = "Content-ID"
; No category.   RFC4229;
#MHD_HTTP_HEADER_CONTENT_MD5 = "Content-MD5"
; No category.   RFC4229;
#MHD_HTTP_HEADER_CONTENT_SCRIPT_TYPE = "Content-Script-Type"
; No category.   RFC4229;
#MHD_HTTP_HEADER_CONTENT_STYLE_TYPE = "Content-Style-Type"
; No category.   RFC4229;
#MHD_HTTP_HEADER_CONTENT_VERSION = "Content-Version"
; Standard.      RFC6265;
#MHD_HTTP_HEADER_COOKIE = "Cookie"
; Obsoleted.     RFC2965; RFC6265;
#MHD_HTTP_HEADER_COOKIE2 = "Cookie2"
; Standard.      RFC5323;
#MHD_HTTP_HEADER_DASL = "DASL"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_DAV = "DAV"
; No category.   RFC4229;
#MHD_HTTP_HEADER_DEFAULT_STYLE = "Default-Style"
; No category.   RFC4229;
#MHD_HTTP_HEADER_DELTA_BASE = "Delta-Base"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_DEPTH = "Depth"
; No category.   RFC4229;
#MHD_HTTP_HEADER_DERIVED_FROM = "Derived-From"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_DESTINATION = "Destination"
; No category.   RFC4229;
#MHD_HTTP_HEADER_DIFFERENTIAL_ID = "Differential-ID"
; No category.   RFC4229;
#MHD_HTTP_HEADER_DIGEST = "Digest"
; Standard.      RFC8470;
#MHD_HTTP_HEADER_EARLY_DATA = "Early-Data"
; Experimental.  RFC-ietf-httpbis-expect-ct-08;
#MHD_HTTP_HEADER_EXPECT_CT = "Expect-CT"
; No category.   RFC4229;
#MHD_HTTP_HEADER_EXT = "Ext"
; Standard.      RFC7239;
#MHD_HTTP_HEADER_FORWARDED = "Forwarded"
; No category.   RFC4229;
#MHD_HTTP_HEADER_GETPROFILE = "GetProfile"
; Experimental.  RFC7486, Section 6.1.1;
#MHD_HTTP_HEADER_HOBAREG = "Hobareg"
; Standard.      RFC7540, Section 3.2.1;
#MHD_HTTP_HEADER_HTTP2_SETTINGS = "HTTP2-Settings"
; No category.   RFC4229;
#MHD_HTTP_HEADER_IM = "IM"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_IF = "If"
; Standard.      RFC6638;
#MHD_HTTP_HEADER_IF_SCHEDULE_TAG_MATCH = "If-Schedule-Tag-Match"
; Standard.      RFC8473;
#MHD_HTTP_HEADER_INCLUDE_REFERRED_TOKEN_BINDING_ID = "Include-Referred-Token-Binding-ID"
; No category.   RFC4229;
#MHD_HTTP_HEADER_KEEP_ALIVE = "Keep-Alive"
; No category.   RFC4229;
#MHD_HTTP_HEADER_LABEL = "Label"
; Standard.      RFC8288;
#MHD_HTTP_HEADER_LINK = "Link"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_LOCK_TOKEN = "Lock-Token"
; No category.   RFC4229;
#MHD_HTTP_HEADER_MAN = "Man"
; Informational. RFC7089;
#MHD_HTTP_HEADER_MEMENTO_DATETIME = "Memento-Datetime"
; No category.   RFC4229;
#MHD_HTTP_HEADER_METER = "Meter"
; No category.   RFC4229;
#MHD_HTTP_HEADER_NEGOTIATE = "Negotiate"
; No category.   RFC4229;
#MHD_HTTP_HEADER_OPT = "Opt"
; Experimental.  RFC8053, Section 3;
#MHD_HTTP_HEADER_OPTIONAL_WWW_AUTHENTICATE = "Optional-WWW-Authenticate"
; Standard.      RFC4229;
#MHD_HTTP_HEADER_ORDERING_TYPE = "Ordering-Type"
; Standard.      RFC6454;
#MHD_HTTP_HEADER_ORIGIN = "Origin"
; Standard.      RFC-ietf-core-object-security-16, Section 11.1;
#MHD_HTTP_HEADER_OSCORE = "OSCORE"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_OVERWRITE = "Overwrite"
; No category.   RFC4229;
#MHD_HTTP_HEADER_P3P = "P3P"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PEP = "PEP"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PICS_LABEL = "PICS-Label"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PEP_INFO = "Pep-Info"
; Standard.      RFC4229;
#MHD_HTTP_HEADER_POSITION = "Position"
; Standard.      RFC7240;
#MHD_HTTP_HEADER_PREFER = "Prefer"
; Standard.      RFC7240;
#MHD_HTTP_HEADER_PREFERENCE_APPLIED = "Preference-Applied"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROFILEOBJECT = "ProfileObject"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROTOCOL = "Protocol"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROTOCOL_INFO = "Protocol-Info"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROTOCOL_QUERY = "Protocol-Query"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROTOCOL_REQUEST = "Protocol-Request"
; Standard.      RFC7615, Section 4;
#MHD_HTTP_HEADER_PROXY_AUTHENTICATION_INFO = "Proxy-Authentication-Info"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROXY_FEATURES = "Proxy-Features"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PROXY_INSTRUCTION = "Proxy-Instruction"
; No category.   RFC4229;
#MHD_HTTP_HEADER_PUBLIC = "Public"
; Standard.      RFC7469;
#MHD_HTTP_HEADER_PUBLIC_KEY_PINS = "Public-Key-Pins"
; Standard.      RFC7469;
#MHD_HTTP_HEADER_PUBLIC_KEY_PINS_REPORT_ONLY = "Public-Key-Pins-Report-Only"
; No category.   RFC4437;
#MHD_HTTP_HEADER_REDIRECT_REF = "Redirect-Ref"
; Standard.      RFC8555, Section 6.5.1;
#MHD_HTTP_HEADER_REPLAY_NONCE = "Replay-Nonce"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SAFE = "Safe"
; Standard.      RFC6638;
#MHD_HTTP_HEADER_SCHEDULE_REPLY = "Schedule-Reply"
; Standard.      RFC6638;
#MHD_HTTP_HEADER_SCHEDULE_TAG = "Schedule-Tag"
; Standard.      RFC8473;
#MHD_HTTP_HEADER_SEC_TOKEN_BINDING = "Sec-Token-Binding"
; Standard.      RFC6455;
#MHD_HTTP_HEADER_SEC_WEBSOCKET_ACCEPT = "Sec-WebSocket-Accept"
; Standard.      RFC6455;
#MHD_HTTP_HEADER_SEC_WEBSOCKET_EXTENSIONS = "Sec-WebSocket-Extensions"
; Standard.      RFC6455;
#MHD_HTTP_HEADER_SEC_WEBSOCKET_KEY = "Sec-WebSocket-Key"
; Standard.      RFC6455;
#MHD_HTTP_HEADER_SEC_WEBSOCKET_PROTOCOL = "Sec-WebSocket-Protocol"
; Standard.      RFC6455;
#MHD_HTTP_HEADER_SEC_WEBSOCKET_VERSION = "Sec-WebSocket-Version"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SECURITY_SCHEME = "Security-Scheme"
; Standard.      RFC6265;
#MHD_HTTP_HEADER_SET_COOKIE = "Set-Cookie"
; Obsoleted.     RFC2965; RFC6265;
#MHD_HTTP_HEADER_SET_COOKIE2 = "Set-Cookie2"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SETPROFILE = "SetProfile"
; Standard.      RFC5023;
#MHD_HTTP_HEADER_SLUG = "SLUG"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SOAPACTION = "SoapAction"
; No category.   RFC4229;
#MHD_HTTP_HEADER_STATUS_URI = "Status-URI"
; Standard.      RFC6797;
#MHD_HTTP_HEADER_STRICT_TRANSPORT_SECURITY = "Strict-Transport-Security"
; Informational. RFC8594;
#MHD_HTTP_HEADER_SUNSET = "Sunset"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SURROGATE_CAPABILITY = "Surrogate-Capability"
; No category.   RFC4229;
#MHD_HTTP_HEADER_SURROGATE_CONTROL = "Surrogate-Control"
; No category.   RFC4229;
#MHD_HTTP_HEADER_TCN = "TCN"
; Standard.      RFC4918;
#MHD_HTTP_HEADER_TIMEOUT = "Timeout"
; Standard.      RFC8030, Section 5.4;
#MHD_HTTP_HEADER_TOPIC = "Topic"
; Standard.      RFC8030, Section 5.2;
#MHD_HTTP_HEADER_TTL = "TTL"
; Standard.      RFC8030, Section 5.3;
#MHD_HTTP_HEADER_URGENCY = "Urgency"
; No category.   RFC4229;
#MHD_HTTP_HEADER_URI = "URI"
; No category.   RFC4229;
#MHD_HTTP_HEADER_VARIANT_VARY = "Variant-Vary"
; No category.   RFC4229;
#MHD_HTTP_HEADER_WANT_DIGEST = "Want-Digest"
; Standard.      https://fetch.spec.whatwg.org/#x-content-type-options-header;
#MHD_HTTP_HEADER_X_CONTENT_TYPE_OPTIONS = "X-Content-Type-Options"
; Informational. RFC7034;
#MHD_HTTP_HEADER_X_FRAME_OPTIONS = "X-Frame-Options"


;-> HTTP Versions
; These strings should be used to match against the first line of the HTTP header.
#MHD_HTTP_VERSION_1_0 = "HTTP/1.0"
#MHD_HTTP_VERSION_1_1 = "HTTP/1.1"


;-> HTTP Methods
; HTTP methods (as strings).
; See: http://www.iana.org/assignments/http-methods/http-methods.xml

; Main HTTP methods.
; Not safe. Not idempotent. RFC7231, Section 4.3.6.;
#MHD_HTTP_METHOD_CONNECT = "CONNECT"
; Not safe. Idempotent.     RFC7231, Section 4.3.5.;
#MHD_HTTP_METHOD_DELETE = "DELETE"
; Safe.     Idempotent.     RFC7231, Section 4.3.1.;
#MHD_HTTP_METHOD_GET = "GET"
; Safe.     Idempotent.     RFC7231, Section 4.3.2.;
#MHD_HTTP_METHOD_HEAD = "HEAD"
; Safe.     Idempotent.     RFC7231, Section 4.3.7.;
#MHD_HTTP_METHOD_OPTIONS = "OPTIONS"
; Not safe. Not idempotent. RFC7231, Section 4.3.3.;
#MHD_HTTP_METHOD_POST = "POST"
; Not safe. Idempotent.     RFC7231, Section 4.3.4.;
#MHD_HTTP_METHOD_PUT = "PUT"
; Safe.     Idempotent.     RFC7231, Section 4.3.8.;
#MHD_HTTP_METHOD_TRACE = "TRACE"

;-> Additional HTTP methods.
; Not safe. Idempotent.     RFC3744, Section 8.1.;
#MHD_HTTP_METHOD_ACL = "ACL"
; Not safe. Idempotent.     RFC3253, Section 12.6.;
#MHD_HTTP_METHOD_BASELINE_CONTROL = "BASELINE-CONTROL"
; Not safe. Idempotent.     RFC5842, Section 4.;
#MHD_HTTP_METHOD_BIND = "BIND"
; Not safe. Idempotent.     RFC3253, Section 4.4, Section 9.4.;
#MHD_HTTP_METHOD_CHECKIN = "CHECKIN"
; Not safe. Idempotent.     RFC3253, Section 4.3, Section 8.8.;
#MHD_HTTP_METHOD_CHECKOUT = "CHECKOUT"
; Not safe. Idempotent.     RFC4918, Section 9.8.;
#MHD_HTTP_METHOD_COPY = "COPY"
; Not safe. Idempotent.     RFC3253, Section 8.2.;
#MHD_HTTP_METHOD_LABEL = "LABEL"
; Not safe. Idempotent.     RFC2068, Section 19.6.1.2.;
#MHD_HTTP_METHOD_LINK = "LINK"
; Not safe. Not idempotent. RFC4918, Section 9.10.;
#MHD_HTTP_METHOD_LOCK = "LOCK"
; Not safe. Idempotent.     RFC3253, Section 11.2.;
#MHD_HTTP_METHOD_MERGE = "MERGE"
; Not safe. Idempotent.     RFC3253, Section 13.5.;
#MHD_HTTP_METHOD_MKACTIVITY = "MKACTIVITY"
; Not safe. Idempotent.     RFC4791, Section 5.3.1; RFC8144, Section 2.3.;
#MHD_HTTP_METHOD_MKCALENDAR = "MKCALENDAR"
; Not safe. Idempotent.     RFC4918, Section 9.3; RFC5689, Section 3; RFC8144, Section 2.3.;
#MHD_HTTP_METHOD_MKCOL = "MKCOL"
; Not safe. Idempotent.     RFC4437, Section 6.;
#MHD_HTTP_METHOD_MKREDIRECTREF = "MKREDIRECTREF"
; Not safe. Idempotent.     RFC3253, Section 6.3.;
#MHD_HTTP_METHOD_MKWORKSPACE = "MKWORKSPACE"
; Not safe. Idempotent.     RFC4918, Section 9.9.;
#MHD_HTTP_METHOD_MOVE = "MOVE"
; Not safe. Idempotent.     RFC3648, Section 7.;
#MHD_HTTP_METHOD_ORDERPATCH = "ORDERPATCH"
; Not safe. Not idempotent. RFC5789, Section 2.;
#MHD_HTTP_METHOD_PATCH = "PATCH"
; Safe.     Idempotent.     RFC7540, Section 3.5.;
#MHD_HTTP_METHOD_PRI = "PRI"
; Safe.     Idempotent.     RFC4918, Section 9.1; RFC8144, Section 2.1.;
#MHD_HTTP_METHOD_PROPFIND = "PROPFIND"
; Not safe. Idempotent.     RFC4918, Section 9.2; RFC8144, Section 2.2.;
#MHD_HTTP_METHOD_PROPPATCH = "PROPPATCH"
; Not safe. Idempotent.     RFC5842, Section 6.;
#MHD_HTTP_METHOD_REBIND = "REBIND"
; Safe.     Idempotent.     RFC3253, Section 3.6; RFC8144, Section 2.1.;
#MHD_HTTP_METHOD_REPORT = "REPORT"
; Safe.     Idempotent.     RFC5323, Section 2.;
#MHD_HTTP_METHOD_SEARCH = "SEARCH"
; Not safe. Idempotent.     RFC5842, Section 5.;
#MHD_HTTP_METHOD_UNBIND = "UNBIND"
; Not safe. Idempotent.     RFC3253, Section 4.5.;
#MHD_HTTP_METHOD_UNCHECKOUT = "UNCHECKOUT"
; Not safe. Idempotent.     RFC2068, Section 19.6.1.3.;
#MHD_HTTP_METHOD_UNLINK = "UNLINK"
; Not safe. Idempotent.     RFC4918, Section 9.11.;
#MHD_HTTP_METHOD_UNLOCK = "UNLOCK"
; Not safe. Idempotent.     RFC3253, Section 7.1.;
#MHD_HTTP_METHOD_UPDATE = "UPDATE"
; Not safe. Idempotent.     RFC4437, Section 7.;
#MHD_HTTP_METHOD_UPDATEREDIRECTREF = "UPDATEREDIRECTREF"
; Not safe. Idempotent.     RFC3253, Section 3.5.;
#MHD_HTTP_METHOD_VERSION_CONTROL = "VERSION-CONTROL"


;-> HTTP POST encodings
; See also: http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4
#MHD_HTTP_POST_ENCODING_FORM_URLENCODED = "application/x-www-form-urlencoded"
#MHD_HTTP_POST_ENCODING_MULTIPART_FORMDATA = "multipart/form-data"

;}


;- Enumerations
;{

;-> MHD_Result

Enumeration MHD_Result
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; MHD-internal Return code For = "NO".
	#MHD_NO = 0
	
	; MHD-internal Return code For = "YES".
	#MHD_YES = 1
EndEnumeration


;-> MHD_FLAG

; Flags for the `struct MHD_Daemon`.
; 
; Note that MHD will run automatically in background thread(s) only
; if #MHD_USE_INTERNAL_POLLING_THREAD is used. Otherwise caller (application)
; must use #MHD_run() or #MHD_run_from_select() to have MHD processed
; network connections and data.
; 
; Starting the daemon may also fail if a particular option is not
; implemented or not supported on the target platform (i.e. no
; support for TLS, epoll or IPv6).
EnumerationBinary MHD_FLAG
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; No options selected.
	#MHD_NO_FLAG = 0
	
	; Print errors messages to custom error logger or to `stderr` if
	; custom error logger is not set.
	; @sa ::MHD_OPTION_EXTERNAL_LOGGER
	#MHD_USE_ERROR_LOG = 1
	
	; Run in debug mode.  If this flag is used, the library should
	; print error messages and warnings to `stderr`.
	; /
	#MHD_USE_DEBUG = 1
	
	; Run in HTTPS mode.  The modern protocol is called TLS.
	#MHD_USE_TLS = 2
	#MHD_USE_SSL = 2  ; Deprecated variant of "#MHD_USE_TLS"
	
	;  Run using one thread per connection.
	;  Must be used only with #MHD_USE_INTERNAL_POLLING_THREAD.
	#MHD_USE_THREAD_PER_CONNECTION = 4
	
	; Run using an internal thread (or thread pool) for sockets sending
	;  and receiving and data processing. Without this flag MHD will not
	;  run automatically in background thread(s).
	; If this flag is set, #MHD_run() and #MHD_run_from_select() couldn't
	;  be used.
	; This flag is set explicitly by #MHD_USE_POLL_INTERNAL_THREAD and
	;  by #MHD_USE_EPOLL_INTERNAL_THREAD.
	#MHD_USE_INTERNAL_POLLING_THREAD = 8
	#MHD_USE_SELECT_INTERNALLY = 8  ; Deprecated variant of "#MHD_USE_INTERNAL_POLLING_THREAD"
	
	; Run using the IPv6 protocol (otherwise, MHD will just support IPv4).
	; If you want MHD To support IPv4 And IPv6 using a single
	;  socket, pass #MHD_USE_DUAL_STACK, otherwise, if you only pass
	;  this option, MHD will try to bind to IPv6-only (resulting in
	;  no IPv4 support).
	#MHD_USE_IPv6 = 16
	
	;  Be pedantic about the protocol (as opposed to as tolerant as
	;  possible).  Specifically, at the moment, this flag causes MHD to
	;  reject HTTP 1.1 connections without a "Host" header.  This is
	;  required by the standard, but of course in violation of the "be
	;  as liberal as possible in what you accept" norm.  It is
	;  recommended to turn this ON if you are testing clients against
	;  MHD, and OFF in production.
	#MHD_USE_PEDANTIC_CHECKS = 32
	
	; Use `poll()` instead of `select()`. This allows sockets with `fd >=
	;  FD_SETSIZE`.  This option is not compatible with using an
	;  'external' polling mode (as there is no API to get the file
	;  descriptors for the external poll() from MHD) and must also not
	;  be used in combination with #MHD_USE_EPOLL.
	;  @sa ::MHD_FEATURE_POLL, #MHD_USE_POLL_INTERNAL_THREAD
	#MHD_USE_POLL = 64
	
	; Run using an internal thread (or thread pool) doing `poll()`.
	; @sa ::MHD_FEATURE_POLL, #MHD_USE_POLL, #MHD_USE_INTERNAL_POLLING_THREAD
	#MHD_USE_POLL_INTERNAL_THREAD = #MHD_USE_POLL | #MHD_USE_INTERNAL_POLLING_THREAD
	#MHD_USE_POLL_INTERNALLY = #MHD_USE_POLL | #MHD_USE_INTERNAL_POLLING_THREAD  ; Deprecated variant of "#MHD_USE_POLL_INTERNAL_THREAD"
	
	
	; Suppress (automatically) adding the 'Date:' header to HTTP responses.
	; This option should ONLY be used on systems that do not have a clock
	;  and that DO provide other mechanisms for cache control.
	; See also RFC 2616, section 14.18 (exception 3).
	#MHD_USE_SUPPRESS_DATE_NO_CLOCK = 128
	#MHD_SUPPRESS_DATE_NO_CLOCK = 128  ; Deprecated variant of "#MHD_USE_SUPPRESS_DATE_NO_CLOCK"
	
	; Run without a listen socket.  This option only makes sense if
	;  #MHD_add_connection is to be used exclusively to connect HTTP
	;  clients to the HTTP server.  This option is incompatible with
	;  using a thread pool; if it is used, #MHD_OPTION_THREAD_POOL_SIZE
	;  is ignored.
	#MHD_USE_NO_LISTEN_SOCKET = 256
	
	; Use `epoll()` instead of `select()` or `poll()` for the event loop.
	; This option is only available on some systems; using the option on
	;  systems without epoll will cause #MHD_start_daemon to fail.  Using
	;  this option is not supported with #MHD_USE_THREAD_PER_CONNECTION.
	;  @sa ::MHD_FEATURE_EPOLL
	#MHD_USE_EPOLL = 512
	#MHD_USE_EPOLL_LINUX_ONLY = 512  ; Deprecated variant of "#MHD_USE_EPOLL"
	
	; Run using an internal thread (or thread pool) doing `epoll()`.
	; This option is only available on certain platforms; using the option on
	;  platform without `epoll` support will cause #MHD_start_daemon to fail.
	;  @sa ::MHD_FEATURE_EPOLL, #MHD_USE_EPOLL, #MHD_USE_INTERNAL_POLLING_THREAD
	#MHD_USE_EPOLL_INTERNAL_THREAD = #MHD_USE_EPOLL | #MHD_USE_INTERNAL_POLLING_THREAD
	#MHD_USE_EPOLL_INTERNALLY = #MHD_USE_EPOLL | #MHD_USE_INTERNAL_POLLING_THREAD
	#MHD_USE_EPOLL_INTERNALLY_LINUX_ONLY = #MHD_USE_EPOLL | #MHD_USE_INTERNAL_POLLING_THREAD
	
	; Use inter-thread communication channel.
	;  #MHD_USE_ITC can be used with #MHD_USE_INTERNAL_POLLING_THREAD
	;  and is ignored with any "external" mode.
	; It's required for use of #MHD_quiesce_daemon
	;  or #MHD_add_connection.
	; This option is enforced by #MHD_ALLOW_SUSPEND_RESUME or
	;  #MHD_USE_NO_LISTEN_SOCKET.
	;  #MHD_USE_ITC is always used automatically on platforms
	;  where select()/poll()/other ignore shutdown of listen
	;  socket.
	#MHD_USE_ITC = 1024
	#MHD_USE_PIPE_FOR_SHUTDOWN = 1024
	
	; Use a single socket for IPv4 and IPv6.
	#MHD_USE_DUAL_STACK = #MHD_USE_IPv6 | 2048
	
	; Enable `turbo`.  Disables certain calls to `shutdown()`,
	;  enables aggressive non-blocking optimistic reads and
	;  other potentially unsafe optimizations.
	; Most effects only happen with #MHD_USE_EPOLL.
	#MHD_USE_TURBO = 4096
	#MHD_USE_EPOLL_TURBO = 4096
	
	; Enable suspend/resume functions, which also implies setting up
	;  ITC to signal resume.
	#MHD_ALLOW_SUSPEND_RESUME = 8192 | #MHD_USE_ITC
	#MHD_USE_SUSPEND_RESUME = 8192 | #MHD_USE_ITC
	
	; Enable TCP_FASTOPEN option.  This option is only available on Linux with a
	;  kernel >= 3.6.  On other systems, using this option cases #MHD_start_daemon
	;  to fail.
	#MHD_USE_TCP_FASTOPEN = 16384
	
	; You need to set this option if you want to use HTTP "Upgrade".
	;  "Upgrade" may require usage of additional internal resources,
	;  which we do not want to use unless necessary.
	#MHD_ALLOW_UPGRADE = 32768
	
	; Automatically use best available polling function.
	; Choice of polling function is also depend on other daemon options.
	; If #MHD_USE_INTERNAL_POLLING_THREAD is specified then epoll, poll() or
	;  select() will be used (listed in decreasing preference order, first
	;  function available on system will be used).
	; If #MHD_USE_THREAD_PER_CONNECTION is specified then poll() or select()
	;  will be used.
	; If those flags are not specified then epoll or select() will be
	;  used (as the only suitable for MHD_get_fdset())
	#MHD_USE_AUTO = 65536
	
	; Run using an internal thread (or thread pool) with best available on
	;  system polling function.
	; This is combination of #MHD_USE_AUTO and #MHD_USE_INTERNAL_POLLING_THREAD
	;  flags.
	#MHD_USE_AUTO_INTERNAL_THREAD = #MHD_USE_AUTO | #MHD_USE_INTERNAL_POLLING_THREAD
	
	; Flag set to enable post-handshake client authentication
	;  (only useful in combination with #MHD_USE_TLS).
	; #MHD_USE_POST_HANDSHAKE_AUTH_SUPPORT = 1U <<17
	
	; Flag set to enable TLS 1.3 early data.  This has
	;  security implications, be VERY careful when using this.
	; #MHD_USE_INSECURE_TLS_EARLY_DATA = 1U <<18
EndEnumeration



;-> MHD_OPTION

; Passed in the varargs portion of #MHD_start_daemon
Enumeration MHD_OPTION
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; No more options / last option
	; This is used to terminate the VARARGs list
	#MHD_OPTION_END = 0
	
	;  Maximum memory size per connection (followed by a `size_t`).
	;  Default is 32 kb (#MHD_POOL_SIZE_DEFAULT).
	;  Values above 128k are unlikely to result in much benefit, as half
	;  of the memory will be typically used for IO, and TCP buffers are
	;  unlikely to support window sizes above 64k on most systems.
	#MHD_OPTION_CONNECTION_MEMORY_LIMIT = 1
	
	;  Maximum number of concurrent connections to
	;  accept (followed by an `unsigned int`).
	#MHD_OPTION_CONNECTION_LIMIT = 2
	
	;  After how many seconds of inactivity should a
	;  connection automatically be timed out? (followed
	;  by an `unsigned int`; use zero for no timeout).
	#MHD_OPTION_CONNECTION_TIMEOUT = 3
	
	;  Register a function that should be called whenever a request has
	;  been completed (this can be used for application-specific clean
	;  up).  Requests that have never been presented to the application
	;  (via #MHD_AccessHandlerCallback) will not result in
	;  notifications.
	; 
	;  This option should be followed by TWO pointers.  First a pointer
	;  to a function of type #MHD_RequestCompletedCallback and second a
	;  pointer to a closure to pass to the request completed callback.
	;  The second pointer maybe NULL.
	#MHD_OPTION_NOTIFY_COMPLETED = 4
	
	;  Limit on the number of (concurrent) connections made to the
	;  server from the same IP address.  Can be used to prevent one
	;  IP from taking over all of the allowed connections.  If the
	;  same IP tries to establish more than the specified number of
	;  connections, they will be immediately rejected.  The option
	;  should be followed by an `unsigned int`.  The default is
	;  zero, which means no limit on the number of connections
	;  from the same IP address.
	#MHD_OPTION_PER_IP_CONNECTION_LIMIT = 5
	
	;  Bind daemon to the supplied `struct sockaddr`. This option should
	;  be followed by a `struct sockaddr; `.  If #MHD_USE_IPv6 is
	;  specified, the `struct sockaddr*` should point to a `struct
	;  sockaddr_in6`, otherwise to a `struct sockaddr_in`.
	#MHD_OPTION_SOCK_ADDR = 6
	
	;  Specify a function that should be called before parsing the URI from
	;  the client.  The specified callback function can be used for processing
	;  the URI (including the options) before it is parsed.  The URI after
	;  parsing will no longer contain the options, which maybe inconvenient for
	;  logging.  This option should be followed by two arguments, the first
	;  one must be of the form
	; 
	;      void;  my_logger(void; cls, const char; uri, struct MHD_Connection; con)
	; 
	;  where the return value will be passed as
	;  (`* con_cls`) in calls to the #MHD_AccessHandlerCallback
	;  when this request is processed later; returning a
	;  value of NULL has no special significance (however,
	;  note that if you return non-NULL, you can no longer
	;  rely on the first call to the access handler having
	;  `NULL ==; con_cls` on entry;)
	;  "cls" will be set to the second argument following
	;  #MHD_OPTION_URI_LOG_CALLBACK.  Finally, uri will
	;  be the 0-terminated URI of the request.
	; 
	;  Note that during the time of this call, most of the connection's
	;  state is not initialized (as we have not yet parsed the headers).
	;  However, information about the connecting client (IP, socket)
	;  is available.
	; 
	;  The specified function is called only once per request, therefore some
	;  programmers may use it to instantiate their own request objects, freeing
	;  them in the notifier #MHD_OPTION_NOTIFY_COMPLETED.
	#MHD_OPTION_URI_LOG_CALLBACK = 7
	
	;  Memory pointer for the private key (key.pem) to be used by the
	;  HTTPS daemon.  This option should be followed by a
	;  `const char; ` argument.
	;  This should be used in conjunction with #MHD_OPTION_HTTPS_MEM_CERT.
	#MHD_OPTION_HTTPS_MEM_KEY = 8
	
	;  Memory pointer for the certificate (cert.pem) to be used by the
	;  HTTPS daemon.  This option should be followed by a
	;  `const char; ` argument.
	;  This should be used in conjunction with #MHD_OPTION_HTTPS_MEM_KEY.
	#MHD_OPTION_HTTPS_MEM_CERT = 9
	
	;  Daemon credentials type.
	;  Followed by an argument of type
	;  `gnutls_credentials_type_t`.
	#MHD_OPTION_HTTPS_CRED_TYPE = 10
	
	;  Memory pointer to a `const char; ` specifying the
	;  cipher algorithm (default: "NORMAL").
	#MHD_OPTION_HTTPS_PRIORITIES = 11
	
	;  Pass a listen socket for MHD to use (systemd-style).  If this
	;  option is used, MHD will not open its own listen socket(s). The
	;  argument passed must be of type `MHD_socket` and refer to an
	;  existing socket that has been bound to a port and is listening.
	#MHD_OPTION_LISTEN_SOCKET = 12
	
	;  Use the given function for logging error messages.  This option
	;  must be followed by two arguments; the first must be a pointer to
	;  a function of type #MHD_LogCallback and the second a pointer
	;  `void; ` which will be passed as the first argument to the log
	;  callback.
	; 
	;  Note that MHD will not generate any log messages
	;  if it was compiled without the "--enable-messages"
	;  flag being set.
	#MHD_OPTION_EXTERNAL_LOGGER = 13
	
	;  Number (`unsigned int`) of threads in thread pool. Enable
	;  thread pooling by setting this value to to something
	;  greater than 1. Currently, thread mode must be
	;  #MHD_USE_INTERNAL_POLLING_THREAD if thread pooling is enabled
	;  (#MHD_start_daemon returns NULL for an unsupported thread
	;  mode).
	#MHD_OPTION_THREAD_POOL_SIZE = 14
	
	;  Additional options given in an array of `struct MHD_OptionItem`.
	;  The array must be terminated with an entry `{MHD_OPTION_END, 0, NULL}`.
	;  An example for code using #MHD_OPTION_ARRAY is:
	; 
	;      struct MHD_OptionItem ops[] = {
	;        { MHD_OPTION_CONNECTION_LIMIT, 100, NULL },
	;        { MHD_OPTION_CONNECTION_TIMEOUT, 10, NULL },
	;        { MHD_OPTION_END, 0, NULL }
	;      };
	;      d = MHD_start_daemon (0, 8080, NULL, NULL, dh, NULL,
	;                            MHD_OPTION_ARRAY, ops,
	;                            MHD_OPTION_END);
	; 
	;  For options that expect a single pointer argument, the
	;  second member of the `struct MHD_OptionItem` is ignored.
	;  For options that expect two pointer arguments, the first
	;  argument must be cast to `intptr_t`.
	#MHD_OPTION_ARRAY = 15
	
	;  Specify a function that should be called for unescaping escape
	;  sequences in URIs and URI arguments.  Note that this function
	;  will NOT be used by the `struct MHD_PostProcessor`.  If this
	;  option is not specified, the default method will be used which
	;  decodes escape sequences of the form "%HH".  This option should
	;  be followed by two arguments, the first one must be of the form
	; 
	;      size_t my_unescaper(void; cls,
	;                          struct MHD_Connection; c,
	;                          char; s)
	; 
	;  where the return value must be the length of the value left in
	;  "s" (without the 0-terminator) and "s" should be updated.  Note
	;  that the unescape function must not lengthen "s" (the result must
	;  be shorter than the input and must still be 0-terminated).
	;  However, it may also include binary zeros before the
	;  0-termination.  "cls" will be set to the second argument
	;  following #MHD_OPTION_UNESCAPE_CALLBACK.
	#MHD_OPTION_UNESCAPE_CALLBACK = 16
	
	;  Memory pointer for the random values to be used by the Digest
	;  Auth module. This option should be followed by two arguments.
	;  First an integer of type  `size_t` which specifies the size
	;  of the buffer pointed to by the second argument in bytes.
	;  Note that the application must ensure that the buffer of the
	;  second argument remains allocated and unmodified while the
	;  deamon is running.
	#MHD_OPTION_DIGEST_AUTH_RANDOM = 17
	
	;  Size of the internal array holding the map of the nonce and
	;  the nonce counter. This option should be followed by an `unsigend int`
	;  argument.
	#MHD_OPTION_NONCE_NC_SIZE = 18
	
	;  Desired size of the stack for threads created by MHD. Followed
	;  by an argument of type `size_t`.  Use 0 for system default.
	#MHD_OPTION_THREAD_STACK_SIZE = 19
	
	;  Memory pointer for the certificate (ca.pem) to be used by the
	;  HTTPS daemon for client authentication.
	;  This option should be followed by a `const char; ` argument.
	#MHD_OPTION_HTTPS_MEM_TRUST = 20
	
	;  Increment to use for growing the read buffer (followed by a
	;  `size_t`). Must fit within #MHD_OPTION_CONNECTION_MEMORY_LIMIT.
	#MHD_OPTION_CONNECTION_MEMORY_INCREMENT = 21
	
	;  Use a callback to determine which X.509 certificate should be
	;  used for a given HTTPS connection.  This option should be
	;  followed by a argument of type `gnutls_certificate_retrieve_function2; `.
	;  This option provides an
	;  alternative to #MHD_OPTION_HTTPS_MEM_KEY,
	;  #MHD_OPTION_HTTPS_MEM_CERT.  You must use this version if
	;  multiple domains are to be hosted at the same IP address using
	;  TLS's Server Name Indication (SNI) extension.  In this case,
	;  the callback is expected to select the correct certificate
	;  based on the SNI information provided.  The callback is expected
	;  to access the SNI data using `gnutls_server_name_get()`.
	;  Using this option requires GnuTLS 3.0 or higher.
	#MHD_OPTION_HTTPS_CERT_CALLBACK = 22
	
	;  When using #MHD_USE_TCP_FASTOPEN, this option changes the default TCP
	;  fastopen queue length of 50.  Note that having a larger queue size can
	;  cause resource exhaustion attack as the TCP stack has to now allocate
	;  resources for the SYN packet along with its DATA.  This option should be
	;  followed by an `unsigned int` argument.
	#MHD_OPTION_TCP_FASTOPEN_QUEUE_SIZE = 23
	
	;  Memory pointer for the Diffie-Hellman parameters (dh.pem) to be used by the
	;  HTTPS daemon for key exchange.
	;  This option must be followed by a `const char; ` argument.
	#MHD_OPTION_HTTPS_MEM_DHPARAMS = 24
	
	;  If present and set to true, allow reusing address:port socket
	;  (by using SO_REUSEPORT on most platform, or platform-specific ways).
	;  If present and set to false, disallow reusing address:port socket
	;  (does nothing on most plaform, but uses SO_EXCLUSIVEADDRUSE on Windows).
	;  This option must be followed by a `unsigned int` argument.
	#MHD_OPTION_LISTENING_ADDRESS_REUSE = 25
	
	;  Memory pointer for a password that decrypts the private key (key.pem)
	;  to be used by the HTTPS daemon. This option should be followed by a
	;  `const char; ` argument.
	;  This should be used in conjunction with #MHD_OPTION_HTTPS_MEM_KEY.
	;  @sa ::MHD_FEATURE_HTTPS_KEY_PASSWORD
	#MHD_OPTION_HTTPS_KEY_PASSWORD = 26
	
	;  Register a function that should be called whenever a connection is
	;  started or closed.
	; 
	;  This option should be followed by TWO pointers.  First a pointer
	;  to a function of type #MHD_NotifyConnectionCallback and second a
	;  pointer to a closure to pass to the request completed callback.
	;  The second pointer maybe NULL.
	#MHD_OPTION_NOTIFY_CONNECTION = 27
	
	;  Allow to change maximum length of the queue of pending connections on
	;  listen socket. If not present than default platform-specific SOMAXCONN
	;  value is used. This option should be followed by an `unsigned int`
	;  argument.
	#MHD_OPTION_LISTEN_BACKLOG_SIZE = 28
	
	;  If set to 1 - be strict about the protocol.  Use -1 to be
	;  as tolerant as possible.
	; 
	;  Specifically, at the moment, at 1 this flag
	;  causes MHD to reject HTTP 1.1 connections without a "Host" header,
	;  and to disallow spaces in the URL or (at -1) in HTTP header key strings.
	; 
	;  These are required by some versions of the standard, but of
	;  course in violation of the "be as liberal as possible in what you
	;  accept" norm.  It is recommended to set this to 1 if you are
	;  testing clients against MHD, and 0 in production.  This option
	;  should be followed by an `int` argument.
	#MHD_OPTION_STRICT_FOR_CLIENT = 29
	
	;  This should be a pointer to callback of type
	;  gnutls_psk_server_credentials_function that will be given to
	;  gnutls_psk_set_server_credentials_function. It is used to
	;  retrieve the shared key for a given username.
	#MHD_OPTION_GNUTLS_PSK_CRED_HANDLER = 30
	
	;  Use a callback to determine which X.509 certificate should be
	;  used for a given HTTPS connection.  This option should be
	;  followed by a argument of type `gnutls_certificate_retrieve_function3; `.
	;  This option provides an
	;  alternative/extension to #MHD_OPTION_HTTPS_CERT_CALLBACK.
	; * You must use this version If you want To use OCSP stapling.
	;  Using this option requires GnuTLS 3.6.3 or higher.
	#MHD_OPTION_HTTPS_CERT_CALLBACK2 = 31
	
	; Allows the application to disable certain sanity precautions
	;  in MHD. With these, the client can break the HTTP protocol,
	;  so this should never be used in production. The options are,
	;  however, useful for testing HTTP clients against "broken"
	;  server implementations.
	; This argument must be followed by an "unsigned int", corresponding
	;  to an `enum MHD_DisableSanityCheck`.
	#MHD_OPTION_SERVER_INSANITY = 32
	
	; If followed by value '1' informs MHD that SIGPIPE is suppressed or
	;  handled by application. Allows MHD to use network functions that could
	;  generate SIGPIPE, like `sendfile()`.
	; Valid only for daemons without #MHD_USE_INTERNAL_POLLING_THREAD as
	;  MHD automatically suppresses SIGPIPE for threads started by MHD.
	; This option should be followed by an `int` argument.
	;  @note Available since #MHD_VERSION 0x00097205
	#MHD_OPTION_SIGPIPE_HANDLED_BY_APP = 33
	
	; If followed by 'int' with value '1' disables usage of ALPN for TLS
	;  connections even if supported by TLS library.
	; Valid only for daemons with #MHD_USE_TLS.
	; This option should be followed by an `int` argument.
	;  @note Available since #MHD_VERSION 0x00097207
	#MHD_OPTION_TLS_NO_ALPN = 34
EndEnumeration


;-> MHD_DisableSanityCheck

; Bitfield for the #MHD_OPTION_SERVER_INSANITY specifying
;  which santiy checks should be disabled.
EnumerationBinary MHD_DisableSanityCheck
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_FLAGS_ENUM')
	
	;All sanity checks are enabled.
	#MHD_DSC_SANE = 0
EndEnumeration


;-> MHD_ValueKind

; The `enum MHD_ValueKind` specifies the source of
;  the key-value pairs in the HTTP protocol.
EnumerationBinary MHD_ValueKind
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; Response header
	#MHD_RESPONSE_HEADER_KIND = 0  ; Deprecated And Not used")
	
	; HTTP header (request/response).
	#MHD_HEADER_KIND = 1
	
	; Cookies.  Note that the original HTTP header containing
	;  the cookie(s) will still be available and intact.
	#MHD_COOKIE_KIND = 2
	
	; POST data.  This is available only if a content encoding
	;  supported by MHD is used (currently only URL encoding),
	;  and only if the posted content fits within the available
	;  memory pool.  Note that in that case, the upload data
	;  given to the #MHD_AccessHandlerCallback will be
	;  empty (since it has already been processed).
	#MHD_POSTDATA_KIND = 4
	
	; GET (URI) arguments.
	#MHD_GET_ARGUMENT_KIND = 8
	
	; HTTP footer (only for HTTP 1.1 chunked encodings).
	#MHD_FOOTER_KIND = 16
EndEnumeration


;-> MHD_RequestTerminationCode

; The `enum MHD_RequestTerminationCode` specifies reasons
;  why a request has been terminated (or completed).
Enumeration MHD_RequestTerminationCode
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	;  We finished sending the response.
	#MHD_REQUEST_TERMINATED_COMPLETED_OK = 0
	
	;  Error handling the connection (resources
	;  exhausted, other side closed connection,
	;  application error accepting request, etc.)
	#MHD_REQUEST_TERMINATED_WITH_ERROR = 1
	
	;  No activity on the connection for the number
	;  of seconds specified using
	;  #MHD_OPTION_CONNECTION_TIMEOUT.
	#MHD_REQUEST_TERMINATED_TIMEOUT_REACHED = 2
	
	;  We had to close the session since MHD was being
	;  shut down.
	#MHD_REQUEST_TERMINATED_DAEMON_SHUTDOWN = 3
	
	;  We tried to read additional data, but the other side closed the
	;  connection.  This error is similar to
	;  #MHD_REQUEST_TERMINATED_WITH_ERROR, but specific to the case where
	;  the connection died because the other side did not send expected
	;  data.
	#MHD_REQUEST_TERMINATED_READ_ERROR = 4
	
	;  The client terminated the connection by closing the socket
	;  for writing (TCP half-closed); MHD aborted sending the
	;  response according to RFC 2616, section 8.1.4.
	;  @ingroup request
	#MHD_REQUEST_TERMINATED_CLIENT_ABORT = 5
EndEnumeration


;-> MHD_ConnectionNotificationCode

; The `enum MHD_ConnectionNotificationCode` specifies types of connection notifications.
Enumeration MHD_ConnectionNotificationCode
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; A new connection has been started.
	#MHD_CONNECTION_NOTIFY_STARTED = 0
	
	; A connection is closed.
	#MHD_CONNECTION_NOTIFY_CLOSED = 1
EndEnumeration


;-> MHD_ConnectionInfoType

; Values of this enum are used To specify what
;  information about a connection is desired.
Enumeration MHD_ConnectionInfoType
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; What cipher algorithm is being used.
	; Takes no extra arguments.
	#MHD_CONNECTION_INFO_CIPHER_ALGO
	
	; Takes no extra arguments.
	#MHD_CONNECTION_INFO_PROTOCOL
	
	; Obtain IP address of the client.  Takes no extra arguments.
	; Returns essentially a `struct sockaddr **` (since the API returns
	;  a `union MHD_ConnectionInfo *` and that union contains a `struct
	;  sockaddr *`).
	#MHD_CONNECTION_INFO_CLIENT_ADDRESS
	
	; Get the gnuTLS session handle.
	#MHD_CONNECTION_INFO_GNUTLS_SESSION
	
	; Get the gnuTLS client certificate handle.  Dysfunctional (never
	;  implemented, deprecated).  Use #MHD_CONNECTION_INFO_GNUTLS_SESSION
	;  to get the `gnutls_session_t` and then call
	;  gnutls_certificate_get_peers().
	#MHD_CONNECTION_INFO_GNUTLS_CLIENT_CERT
	
	;   Get the `struct MHD_Daemon *` responsible for managing this connection.
	#MHD_CONNECTION_INFO_DAEMON
	
	; Request the file descriptor for the connection socket.
	; #MHD sockets are always in non-blocking mode.
	; No extra arguments should be passed.
	#MHD_CONNECTION_INFO_CONNECTION_FD
	
	; Returns the client-specific pointer to a `void *` that was (possibly)
	;  set during a #MHD_NotifyConnectionCallback when the socket was
	;  first accepted.  Note that this is NOT the same as the "con_cls"
	;  argument of the #MHD_AccessHandlerCallback.  The "con_cls" is
	;  fresh for each HTTP request, while the "socket_context" is fresh
	;  for each socket.
	#MHD_CONNECTION_INFO_SOCKET_CONTEXT
	
	; Check whether the connection is suspended.
	#MHD_CONNECTION_INFO_CONNECTION_SUSPENDED
	
	; Get connection timeout
	#MHD_CONNECTION_INFO_CONNECTION_TIMEOUT
	
	; Return length of the client's HTTP request header.
	#MHD_CONNECTION_INFO_REQUEST_HEADER_SIZE
	
	; Return HTTP status queued with the response. NULL
	;  if no HTTP response has been queued yet.
	#MHD_CONNECTION_INFO_HTTP_STATUS
EndEnumeration


;-> MHD_DaemonInfoType

; Values of this enum are used to specify what
;  information about a daemon is desired.
Enumeration MHD_DaemonInfoType
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; No longer supported (will return NULL).
	#MHD_DAEMON_INFO_KEY_SIZE
	
	; No longer supported (will return NULL).
	#MHD_DAEMON_INFO_MAC_KEY_SIZE
	
	; Request the file descriptor for the listening socket.
	; No extra arguments should be passed.
	#MHD_DAEMON_INFO_LISTEN_FD
	
	; Request the file descriptor for the "external" sockets polling
	;  when 'epoll' mode is used.
	; No extra arguments should be passed.
	; 
	; Waiting on epoll FD must not block longer than value
	;  returned by #MHD_get_timeout() otherwise connections
	;  will "hung" with unprocessed data in network buffers
	;  and timed-out connections will not be closed.
	#MHD_DAEMON_INFO_EPOLL_FD_LINUX_ONLY
	#MHD_DAEMON_INFO_EPOLL_FD = #MHD_DAEMON_INFO_EPOLL_FD_LINUX_ONLY
	
	; Request the number of current connections handled by the daemon.
	; No extra arguments should be passed.
	; Note: when using MHD in "external" polling mode, this type of request
	;   could be used only when #MHD_run()/#MHD_run_from_select is not
	;   working in other thread at the same time.
	#MHD_DAEMON_INFO_CURRENT_CONNECTIONS
	
	; Request the daemon flags.
	; No extra arguments should be passed.
	; Note: flags may differ from original 'flags' specified for
	;  daemon, especially if #MHD_USE_AUTO was set.
	#MHD_DAEMON_INFO_FLAGS
	
	; Request the port number of daemon's listen socket.
	; No extra arguments should be passed.
	; Note: if port '0' was specified for #MHD_start_daemon(), returned
	;  value will be real port number.
	#MHD_DAEMON_INFO_BIND_PORT
EndEnumeration


; TODO: Find more ?


;-> MHD_ResponseMemoryMode

Enumeration MHD_ResponseMemoryMode
	; Structure size: 4 bytes  (Derived from '_MHD_FIXED_ENUM')
	
	; Buffer is a persistent (static/global) buffer that won't change for at
	;  least the lifetime of the response, MHD should just use it, not free it,
	;  not copy it, just keep an alias to it.
	#MHD_RESPMEM_PERSISTENT
	
	; Buffer is heap-allocated with `malloc()` (or equivalent) and
	;  should be freed by MHD after processing the response has
	;  concluded (response reference counter reaches zero).
	#MHD_RESPMEM_MUST_FREE
	
	; Buffer is in transient memory, but not on the heap (for example, on the
	;  stack or non-`malloc()` allocated) and only valid during the call to
	;  #MHD_create_response_from_buffer.
	; MHD must make its own private copy of the data for processing.
	#MHD_RESPMEM_MUST_COPY
EndEnumeration

;}


;- Callback signatures
;{

; Type of a callback function used for logging by MHD.
; @param cls closure
; @param fm format string (`printf()`-style)
; @param ap arguments to @a fm
; MHD_LogCallback(*cls, *fm, *ap) ; FIXME: Fix the typing !!!
; typedef void (*MHD_LogCallback)(void *cls, const char *fm, va_list ap);


;-> *MHD_PskServerCredentialsCallback
; /**
;  * Function called To lookup the pre Shared key (@a psk) For a given
;  * HTTP connection based on the @a username.
;  *
;  * @param cls closure
;  * @param connection the HTTPS connection
;  * @param username the user name claimed by the other side
;  * @param[out] psk To be set To the pre-Shared-key; should be allocated with malloc(),
;  *                 will be freed by MHD
;  * @param[out] psk_size To be set To the number of bytes in @a psk
;  * @return 0 on success, -1 on errors
;  */
; typedef int
; (*MHD_PskServerCredentialsCallback)(void *cls,
;                                     const struct MHD_Connection *connection,
;                                     const char *username,
;                                     void **psk,
;                                     size_t *psk_size);


;-> *MHD_PanicCallback
; /**
;  * Callback For serious error condition. The Default action is To print
;  * an error message And `abort()`.
;  *
;  * @param cls user specified value
;  * @param file where the error occurred
;  * @param line where the error occurred
;  * @param reason error detail, may be NULL
;  * @ingroup logging
;  */
; typedef void
; (*MHD_PanicCallback) (void *cls,
;                       const char *file,
;                       unsigned int line,
;                       const char *reason);


;-> *MHD_AcceptPolicyCallback
; Allow or deny a client to connect.
; @param cls closure
; @param addr address information from the client
; @param addrlen length of @a addr
; @return #MHD_YES if connection is allowed, #MHD_NO if Not
; typedef enum MHD_Result
; (*MHD_AcceptPolicyCallback)(void *cls,
;                             const struct sockaddr *addr,
;                             socklen_t addrlen);


;-> *MHD_AccessHandlerCallback
;  A client has requested the given @a url using the given @a method
;  (#MHD_HTTP_METHOD_GET, #MHD_HTTP_METHOD_PUT, #MHD_HTTP_METHOD_DELETE,
;  #MHD_HTTP_METHOD_POST, etc).
; 
;  The callback must call MHD function MHD_queue_response() to provide content
;  to give back to the client and return an HTTP status code (i.e.
;  #MHD_HTTP_OK, #MHD_HTTP_NOT_FOUND, etc.). The response can be created
;  in this callback or prepared in advance.
;  Alternatively, callback may call MHD_suspend_connection() to temporarily
;  suspend data processing for this connection.
; 
;  As soon as response is provided this callback will not be called anymore
;  for the current request.
; 
;  For each HTTP request this callback is called several times:
; ;  after request headers are fully received and decoded,
; ;  for each received part of request body (optional, if request has body),
; ;  when request is fully received.
; 
;  If response is provided before request is fully received, the rest
;  of the request is discarded and connection is automatically closed
;  after sending response.
; 
;  If the request is fully received, but response hasn't been provided and
;  connection is not suspended, the callback can be called again immediately.
; 
;  The response cannot be queued when this callback is called to process
;  the client upload data (when @a upload_data is not NULL).
; 
;  @param cls argument given together with the function
;         pointer when the handler was registered with MHD
;  @param url the requested url
;  @param method the HTTP method used (#MHD_HTTP_METHOD_GET,
;         #MHD_HTTP_METHOD_PUT, etc.)
;  @param version the HTTP version string (i.e.
;         #MHD_HTTP_VERSION_1_1)
;  @param upload_data the data being uploaded (excluding HEADERS,
;         for a POST that fits into memory and that is encoded
;         with a supported encoding, the POST data will NOT be
;         given in upload_data and is instead available as
;         part of #MHD_get_connection_values; very large POST
;         data; will* be made available incrementally in
;         @a upload_data)
;  @param[in,out] upload_data_size set initially to the size of the
;         @a upload_data provided; the method must update this
;         value to the number of bytes NOT processed;
;  @param[in,out] con_cls pointer that the callback can set to some
;         address and that will be preserved by MHD for future
;         calls for this request; since the access handler may
;         be called many times (i.e., for a PUT/POST operation
;         with plenty of upload data) this allows the application
;         to easily associate some request-specific state.
;         If necessary, this state can be cleaned up in the
;         global #MHD_RequestCompletedCallback (which
;         can be set with the #MHD_OPTION_NOTIFY_COMPLETED).
;         Initially, `*con_cls` will be NULL.
;  @return #MHD_YES if the connection was handled successfully,
;          #MHD_NO if the socket must be closed due to a serious
;          error while handling the request
; 
;  @sa #MHD_queue_response()
; /
; typedef enum MHD_Result
; (*MHD_AccessHandlerCallback)(void; cls,
;                              struct MHD_Connection; connection,
;                              const char; url,
;                              const char; method,
;                              const char; version,
;                              const char; upload_data,
;                              size_t; upload_data_size,
;                              void; *con_cls);


;-> *MHD_RequestCompletedCallback
;  Signature of the callback used by MHD to notify the
;  application about completed requests.
; 
;  @param cls client-defined closure
;  @param connection connection handle
;  @param con_cls value as set by the last call to
;         the #MHD_AccessHandlerCallback
;  @param toe reason for request termination
;  @see #MHD_OPTION_NOTIFY_COMPLETED
;  @ingroup request
; /
; typedef void
; (*MHD_RequestCompletedCallback) (void; cls,
;                                  struct MHD_Connection; connection,
;                                  void; *con_cls,
;                                  enum MHD_RequestTerminationCode toe);


;-> *MHD_NotifyConnectionCallback
;  Signature of the callback used by MHD to notify the
;  application about started/stopped connections
; 
;  @param cls client-defined closure
;  @param connection connection handle
;  @param socket_context socket-specific pointer where the
;                        client can associate some state specific
;                        to the TCP connection; note that this is
;                        different from the "con_cls" which is per
;                        HTTP request.  The client can initialize
;                        during #MHD_CONNECTION_NOTIFY_STARTED and
;                        cleanup during #MHD_CONNECTION_NOTIFY_CLOSED
;                        and access in the meantime using
;                        #MHD_CONNECTION_INFO_SOCKET_CONTEXT.
;  @param toe reason for connection notification
;  @see #MHD_OPTION_NOTIFY_CONNECTION
;  @ingroup request
; /
; typedef void
; (*MHD_NotifyConnectionCallback) (void; cls,
;                                  struct MHD_Connection; connection,
;                                  void; *socket_context,
;                                  enum MHD_ConnectionNotificationCode toe);


;-> *MHD_ContentReaderCallback
;  Callback used by libmicrohttpd in order to obtain content.
; 
;  The callback is to copy at most @a max bytes of content into @a buf.
;  The total number of bytes that has been placed into @a buf should be
;  returned.
; 
;  Note that returning zero will cause libmicrohttpd to try again.
;  Thus, returning zero should only be used in conjunction
;  with MHD_suspend_connection() to avoid busy waiting.
; 
;  @param cls extra argument to the callback
;  @param pos position in the datastream to access;
;         note that if a `struct MHD_Response` object is re-used,
;         it is possible for the same content reader to
;         be queried multiple times for the same data;
;         however, if a `struct MHD_Response` is not re-used,
;         libmicrohttpd guarantees that "pos" will be
;         the sum of all non-negative return values
;         obtained from the content reader so far.
;  @param buf where to copy the data
;  @param max maximum number of bytes to copy to @a buf (size of @a buf)
;  @return number of bytes written to @a buf;
;   0 is legal unless MHD is started in "internal" sockets polling mode
;     (since this would cause busy-waiting); 0 in "external" sockets
;     polling mode will cause this function to be called again once
;     any MHD_run*() function is called;
;   #MHD_CONTENT_READER_END_OF_STREAM (-1) for the regular
;     end of transmission (with chunked encoding, MHD will then
;     terminate the chunk and send any HTTP footers that might be
;     present; without chunked encoding and given an unknown
;     response size, MHD will simply close the connection; note
;     that while returning #MHD_CONTENT_READER_END_OF_STREAM is not technically
;     legal if a response size was specified, MHD accepts this
;     and treats it just as #MHD_CONTENT_READER_END_WITH_ERROR;
;   #MHD_CONTENT_READER_END_WITH_ERROR (-2) to indicate a server
;     error generating the response; this will cause MHD to simply
;     close the connection immediately.  If a response size was
;     given or if chunked encoding is in use, this will indicate
;     an error to the client.  Note, however, that if the client
;     does not know a response size and chunked encoding is not in
;     use, then clients will not be able to tell the difference between
;     #MHD_CONTENT_READER_END_WITH_ERROR and #MHD_CONTENT_READER_END_OF_STREAM.
;     This is not a limitation of MHD but rather of the HTTP protocol.
; /
; typedef ssize_t
; (*MHD_ContentReaderCallback) (void; cls,
;                               uint64_t pos,
;                               char; buf,
;                               size_t max);


;-> *MHD_ContentReaderFreeCallback
;  This method is called by libmicrohttpd if we
;  are done with a content reader.  It should
;  be used to free resources associated with the
;  content reader.
; 
;  @param cls closure
;  @ingroup response
; /
; typedef void
; (*MHD_ContentReaderFreeCallback) (void; cls);

;}


;- Other signatures
;{

;-> *MHD_KeyValueIterator
;  Iterator over key-value pairs.  This iterator
;  can be used to iterate over all of the cookies,
;  headers, or POST-data fields of a request, and
;  also to iterate over the headers that have been
;  added to a response.
; 
;  @param cls closure
;  @param kind kind of the header we are looking at
;  @param key key for the value, can be an empty string
;  @param value corresponding value, can be NULL
;  @return #MHD_YES to continue iterating,
;          #MHD_NO to abort the iteration
;  @ingroup request
; /
; typedef enum MHD_Result
; (*MHD_KeyValueIterator)(void; cls,
;                         enum MHD_ValueKind kind,
;                         const char; key,
;                         const char; value);


;-> *MHD_KeyValueIteratorN
;  Iterator over key-value pairs with size parameters.
;  This iterator can be used to iterate over all of
;  the cookies, headers, or POST-data fields of a
;  request, and also to iterate over the headers that
;  have been added to a response.
;  @note Available since #MHD_VERSION 0x00096303
; 
;  @param cls closure
;  @param kind kind of the header we are looking at
;  @param key key for the value, can be an empty string
;  @param value corresponding value, can be NULL
;  @param value_size number of bytes in @a value;
;                    for C-strings, the length excludes the 0-terminator
;  @return #MHD_YES to continue iterating,
;          #MHD_NO to abort the iteration
;  @ingroup request
; /
; typedef enum MHD_Result
; (*MHD_KeyValueIteratorN)(void; cls,
;                          enum MHD_ValueKind kind,
;                          const char; key,
;                          size_t key_size,
;                          const char; value,
;                          size_t value_size);


;-> *MHD_PostDataIterator
;  Iterator over key-value pairs where the value
;  may be made available in increments and/or may
;  not be zero-terminated.  Used for processing
;  POST data.
; 
;  @param cls user-specified closure
;  @param kind type of the value, always #MHD_POSTDATA_KIND when called from MHD
;  @param key 0-terminated key for the value
;  @param filename name of the uploaded file, NULL if not known
;  @param content_type mime-type of the data, NULL if not known
;  @param transfer_encoding encoding of the data, NULL if not known
;  @param data pointer to @a size bytes of data at the
;               specified offset
;  @param off offset of data in the overall value
;  @param size number of bytes in @a data available
;  @return #MHD_YES to continue iterating,
;          #MHD_NO to abort the iteration
; /
; typedef enum MHD_Result
; (*MHD_PostDataIterator)(void; cls,
;                         enum MHD_ValueKind kind,
;                         const char; key,
;                         const char; filename,
;                         const char; content_type,
;                         const char; transfer_encoding,
;                         const char; data,
;                         uint64_t off,
;                         size_t size);

;}


;- Imports
Import #LIBMICROHTTPD_LIBRARY_PATH$
	;-> Uncategorized
	; Returns the string reason phrase for a response code.
	; If message string is not available for a status code, "Unknown" string will be returned.
	MHD_get_reason_phrase_for.i(code.uint)
	; const char * MHD_get_reason_phrase_for (unsigned int code);
	
	; Returns the length of the string reason phrase for a response code.
	; If message string is not available for a status code, 0 is returned.
	MHD_get_reason_phrase_len_for.size_t(code.uint)
	; size_t MHD_get_reason_phrase_len_for (unsigned int code);
	
	
	;-> Daemon handling functions
	
	;  Start a webserver on the given port.
	;  @param flags combination of `enum MHD_FLAG` values
	;  @param port port to bind to (in host byte order),
	;         use '0' to bind to random free port,
	;         ignored if MHD_OPTION_SOCK_ADDR or
	;         MHD_OPTION_LISTEN_SOCKET is provided
	;         or MHD_USE_NO_LISTEN_SOCKET is specified
	;  @param apc callback to call to check which clients
	;         will be allowed to connect; you can pass NULL
	;         in which case connections from any IP will be
	;         accepted
	;  @param apc_cls extra argument to apc
	;  @param dh handler called for all requests (repeatedly)
	;  @param dh_cls extra argument to @a dh
	;  @param ap list of options (type-value pairs,
	;         terminated with #MHD_OPTION_END).
	;  @return NULL on error, handle to daemon on success
	; struct MHD_Daemon MHD_start_daemon_va (unsigned int flags,
	;		     uint16_t port, MHD_AcceptPolicyCallback apc, void; apc_cls,
	;		     MHD_AccessHandlerCallback dh, void; dh_cls, va_list ap);
	MHD_start_daemon_va.i(flags.uint, port.uint16_t, *apc, *apc_cls, *dh, *dh_cls, *ap)
	
	;  Start a webserver on the given port.  Variadic version of
	;  #MHD_start_daemon_va.
	;  @param flags combination of `enum MHD_FLAG` values
	;  @param port port to bind to (in host byte order),
	;         use '0' to bind to random free port,
	;         ignored if MHD_OPTION_SOCK_ADDR or
	;         MHD_OPTION_LISTEN_SOCKET is provided
	;         or MHD_USE_NO_LISTEN_SOCKET is specified
	;  @param apc callback to call to check which clients
	;         will be allowed to connect; you can pass NULL
	;         in which case connections from any IP will be
	;         accepted
	;  @param apc_cls extra argument to apc
	;  @param dh handler called for all requests (repeatedly)
	;  @param dh_cls extra argument to @a dh
	;  @return NULL on error, handle to daemon on success
	;  @ingroup event
	;_MHD_EXTERN struct MHD_Daemon; 
	;MHD_start_daemon (unsigned int flags,
	;		  uint16_t port,
	;		  MHD_AcceptPolicyCallback apc, void; apc_cls,
	;		  MHD_AccessHandlerCallback dh, void; dh_cls,
	;		  ...);
	MHD_start_daemon(flags.uint, port.uint16_t, *apc, *apc_cls, *dh, *dh_cls)
	
	;  Stop accepting connections from the listening socket.  Allows
	;  clients to continue processing, but stops accepting new
	;  connections.  Note that the caller is responsible for closing the
	;  returned socket; however, if MHD is run using threads (anything but
	;  external select mode), it must not be closed until AFTER
	;  #MHD_stop_daemon has been called (as it is theoretically possible
	;  that an existing thread is still using it).
	; 
	;  Note that some thread modes require the caller to have passed
	;  #MHD_USE_ITC when using this API.  If this daemon is
	;  in one of those modes and this option was not given to
	;  #MHD_start_daemon, this function will return #MHD_INVALID_SOCKET.
	; 
	;  @param daemon daemon to stop accepting new connections for
	;  @return old listen socket on success, #MHD_INVALID_SOCKET if
	;          the daemon was already not listening anymore
	; MHD_socket MHD_quiesce_daemon(struct MHD_Daemon *daemon);
	; struct MHD_socket == SOCKET == uint_ptr  (~line 210 in libmicrohttpd.h)
	MHD_quiesce_daemon.i(*daemon)
	
	;  Shutdown an HTTP daemon.
	;  @param daemon daemon to stop
	;  @ingroup event
	;_MHD_EXTERN void
	;MHD_stop_daemon (struct MHD_Daemon; daemon);
	MHD_stop_daemon(*daemon)
	
	
	;-> Connection handling functions
	
	
	
	
	;-> IDK
	
	; Create a response object.
	; The response object can be extended with header information and then be used any number of times.
	; 
	; @param size size of the data portion of the response
	; @param buffer size bytes containing the response's data portion
	; @param mode flags for buffer management
	; Returns #Null on error (i.e. invalid arguments, out of memory)
	MHD_create_response_from_buffer.i(size.size_t, *buffer, mode.b)
	; struct MHD_Response MHD_create_response_from_buffer(size_t size, void; buffer, enum MHD_ResponseMemoryMode mode);
	
	; Queue a response to be transmitted to the client.
	; As soon as possible but after #MHD_AccessHandlerCallback returns.
	; 
	; @param connection the connection identifying the client
	; @param status_code HTTP status code (i.e. #MHD_HTTP_OK)
	; @param response response to transmit
	; Returns #MHD_NO on error (i.e. reply already sent), or #MHD_YES on success or if message has been queued.
	MHD_queue_response.int(*connection, status_code.int, *response)
	; int MHD_queue_response (struct MHD_Connection; connection, unsigned int status_code, struct MHD_Response; response);
	
	
	; Destroy a response object and associated resources.
	; Note that libmicrohttpd may keep some of the resources around if the response
	;  is still in the queue for some clients, so the memory may not necessarily be freed immediatley.
	;  @param response response to destroy
	MHD_destroy_response(*response)
	; void MHD_destroy_response (struct MHD_Response; response);
	
	
	;  Get information about supported MHD features.
	;  Indicate that MHD was compiled with or without support for
	;  particular feature. Some features require additional support
	;  by kernel. Kernel support is not checked by this function.
	; 
	;  @param feature type of requested information
	;  @return #MHD_YES if feature is supported by MHD, #MHD_NO if
	;  feature is not supported or feature is unknown.
	; int MHD_is_feature_supported (enum MHD_FEATURE feature);
	MHD_is_feature_supported.int(feature.int);
	
	; Obtain the version of this library
	; @return Static version string, e.g. "0.9.9"
	; const char * MHD_get_version (void);
	MHD_get_version.i()
EndImport


;- Tests
CompilerIf #PB_Compiler_IsMainFile
	; https://gnu.org/software/libmicrohttpd/tutorial.html
	
	#Page_Content = "<!doctype html><html><head><meta charset='utf-8'></head><body>Hello World !<br>Test àéäù</body></html>"
	
	; Callback
	Procedure.int HTTPRequestCallback(*cls, *connection, *url, *method, *version, *upload_data, *upload_data_size, *con_cls)
		
		Debug "Request:"
		Debug "  * URL: "+PeekS(*url, -1, #PB_UTF8)
		Debug "  * Method: "+PeekS(*method, -1, #PB_UTF8)
		Debug "  * Version: "+PeekS(*version, -1, #PB_UTF8)
		
		Protected *PageContent = AllocateMemory(StringByteLength(#Page_Content, #PB_UTF8))
		PokeS(*PageContent, #Page_Content, -1, #PB_UTF8)
		Protected *Response = #Null
		Protected ReturnValue.int = 0
		
		; #MHD_RESPMEM_PERSISTENT - Messes up the first 8 bytes !
		*Response = MHD_create_response_from_buffer(MemorySize(*PageContent), *PageContent, #MHD_RESPMEM_MUST_COPY)
		ReturnValue = MHD_queue_response(*connection, #MHD_HTTP_OK, *Response)
		MHD_destroy_response(*Response)
		
		FreeMemory(*PageContent)
		
		ProcedureReturn ReturnValue
	EndProcedure
	
	; Main code
	Debug "Testing bindings using libmicrohttpd v"+PeekS(MHD_get_version(), -1, #PB_UTF8)
	Define *HttpServer = MHD_start_daemon(#MHD_USE_INTERNAL_POLLING_THREAD, 8080, #Null, #Null, @HTTPRequestCallback(), #Null)
	
	If Not *HttpServer
		Debug "Failed to start daemon !"
	EndIf
	
	While #True
		Delay(1)
	Wend
	
	MHD_stop_daemon(*HttpServer)
CompilerEndIf
