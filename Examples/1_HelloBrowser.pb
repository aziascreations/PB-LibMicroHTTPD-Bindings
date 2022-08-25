; Feel free to use this example code in any way you see fit (Public Domain)


; https://www.gnu.org/software/libmicrohttpd/tutorial.html#hellobrowser_002ec

;- Compiler Directives
#LIBMICROHTTPD_LIBRARY_PATH_WINDOWS_X64 = "D:\DevelopmentNew\PureBasic\PB-LibMicroHTTPD-Bindings\Binaries\x86_64\VS2022\Release-dll\libmicrohttpd-dll.lib"
XIncludeFile "../LibMicroHTTPD-Bindings.pbi"


;- Constants
#Port = 8080
#Page = "<!doctype html><html><head><meta charset='utf-8'></head><body>Hello, browser!</body></html>"


;- Callback
Procedure.int AnswerToConnection(*cls, *connection, *url, *method, *version, *upload_data, *upload_data_size, *con_cls)
	; Debugging output
	Debug PeekS(*version, -1, #PB_UTF8) + " - " + PeekS(*method, -1, #PB_UTF8) + " - " + PeekS(*url, -1, #PB_UTF8)
	
	; Copying the constant into a buffer in UTF-8
	Protected *PageContent = AllocateMemory(StringByteLength(#Page, #PB_UTF8))
	PokeS(*PageContent, #Page, -1, #PB_UTF8)
	
	; Preparing other variables
	Protected *Response = #Null
	Protected ReturnValue.int = 0
	
	; Composing the response  /!\ "#MHD_RESPMEM_PERSISTENT" Messes up the first 8 bytes -> Could be due to freeing *PageContent /!\
	*Response = MHD_create_response_from_buffer(MemorySize(*PageContent), *PageContent, #MHD_RESPMEM_MUST_COPY)
	
	; Queuing the response to be sent
	ReturnValue = MHD_queue_response(*connection, #MHD_HTTP_OK, *Response)
	
	; Cleaning memory
	MHD_destroy_response(*Response)
	FreeMemory(*PageContent)
	
	; Notifying the deamon of any errors/success
	ProcedureReturn ReturnValue
EndProcedure


;- Main code

; Starting the HTTP server
Define *HttpServer = MHD_start_daemon(#MHD_USE_INTERNAL_POLLING_THREAD, #Port, #Null, #Null, @AnswerToConnection(), #Null)
If Not *HttpServer
	Debug "Failed to start daemon !"
	End 1
EndIf
Debug "Started HTTP server as 'http://127.0.0.1:" + Str(#Port) + "' !"

; Waiting 60s before exiting automatically
; This won't affect the server if it uses different threads for each connection !
Delay(60000)

; Closing down nicely
Debug "Closing down HTTP server..."
MHD_stop_daemon(*HttpServer)

End 0
