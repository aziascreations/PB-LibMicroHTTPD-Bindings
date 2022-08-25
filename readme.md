# W.I.P - PB-LibMicroHTTPD-Bindings
PureBasic bindings for the *libhttpd* library.

## Requirements
* PureBasic 6.00 LTS - C Backend  (5.70 support will come later)
* libhttpd 0.9.75+
* PB-CTypes 1.0.0+

## Development Setup
In order to use these bindings, you need to do the following things:

### 1. Downloading *libhttpd*

#### Linux
Simply run one the following command, depending on your packet manager, to install the development libraries:
```bash
apt install libmicrohttpd-dev
```

#### Windows
Go to one of the following URL and download the appropriate file:<br>
&nbsp;&nbsp;● View all releases: [https://ftp.nluug.nl/pub/gnu/libmicrohttpd/](https://ftp.nluug.nl/pub/gnu/libmicrohttpd/)<br>
&nbsp;&nbsp;● Latest release: [https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest-w32-bin.zip](https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest-w32-bin.zip)

Once downloaded, extract the archive somewhere and keep note of the path like so:<br>
&nbsp;&nbsp;`<path>\libmicrohttpd-<version>-w32-bin\`

### 2. Downloading PureBasic files

#### Single step approach - *recommended*
In order to download the purebasic files, you can simply 


#### Manual approach - *recommended*
If you want to set files manually, you'll need to clone 2 repositoried in a folder where you want your includes to be located with these commands:
```bash
git clone <1>
git clone <2>
```

Alternatively, you can visit the repositories at the following URLs and download and extract them in a similar manner:<br>
&nbsp;&nbsp;● <br>
&nbsp;&nbsp;● 

### 3. Including the bindings
Now that everything is setup, all you have to do is to include the bindings and point to the `.lib` files if you are using Windows like so:
```purebasic
#LIBMICROHTTPD_LIBRARY_PATH$ = "<path>/libmicrohttpd.so"
XIncludeFile "<includes>/PB-LibMicroHTTPD-Bindings/Main.pbi"
```

You can substitute the `#LIBMICROHTTPD_LIBRARY_PATH` constant for one of the following if you intend on supporting multiple acrhitectures in one go:<br>
&nbsp;&nbsp;● `#LIBMICROHTTPD_LIBRARY_PATH_LINUX_ARM64` - Linux ARM64<br>
&nbsp;&nbsp;● `#LIBMICROHTTPD_LIBRARY_PATH_WINDOWS_X64` - Windows x64

**If you are using Windows, you also need to make sure your executable has access to the `libmicrohttpd-dll.dll` file when launched by either including it in the `PATH` or in the same folder as the final executable !**

## Examples


## License
TODO: Still figuring out how it will work with LGPL 2.1...
