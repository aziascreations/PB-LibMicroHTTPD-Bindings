# W.I.P - PB-LibMicroHTTPD-Bindings
PureBasic bindings for the *libmicrohttpd * library.


## Requirements
* PureBasic 6.00 LTS - C Backend  (5.70 support will come later)
* libmicrohttpd  0.9.75+
* PB-CTypes 0.0.1+


## Development Setup
In order to use these bindings, you need to do the following things:

### Downloading *libmicrohttpd*

#### Linux
Run one the following command, depending on your packet manager, to install the development libraries:
```bash
apt install libmicrohttpd-dev
```

#### Windows
Go to one of the following URL and download the appropriate *win32* release archive:<br>
&nbsp;&nbsp;● View all releases: [https://ftp.nluug.nl/pub/gnu/libmicrohttpd/](https://ftp.nluug.nl/pub/gnu/libmicrohttpd/)<br>
&nbsp;&nbsp;● Latest release: [https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest-w32-bin.zip](https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest-w32-bin.zip)

Once downloaded, extract the archive somewhere and keep note of the path for later.

### Downloading PureBasic includes

#### Single step approach - *recommended*
In order to download the purebasic files, you can simply downloads one of the releases on the [release page](https://github.com/aziascreations/PB-LibMicroHTTPD-Bindings/releases) and extract it in your includes folder.

If you download an archive ending with *"-sources"*, you may have to go down one folder in the archive to find the 2 required folders.

#### Manual approach
If you want to set files manually, you'll need to clone 2 repositoried in a folder where you want your includes to be located with these commands:
```bash
git clone https://github.com/aziascreations/PB-LibMicroHTTPD-Bindings.git
git clone https://github.com/aziascreations/PB-CTypes.git
```

Alternatively, you can visit the repositories at the following URLs and download and extract them in a similar manner as described above:<br>
&nbsp;&nbsp;● https://github.com/aziascreations/PB-LibMicroHTTPD-Bindings<br>
&nbsp;&nbsp;● https://github.com/aziascreations/PB-CTypes.git

### Including the bindings
Now that everything is setup, all you have to do is to include the bindings and point to the `.lib` files if you are using Windows like so:
```purebasic
#LIBMICROHTTPD_LIBRARY_PATH$ = "<path>/libmicrohttpd.so"
XIncludeFile "<includes>/PB-LibMicroHTTPD-Bindings/LibMicroHTTPD-Bindings.pbi"
```

Some variants of that constant are available for specific OS and CPU architectures and are **only** used if `#LIBMICROHTTPD_LIBRARY_PATH$` isn't defined:
<table>
<tr>
<td><b>Constant</b></td>
<td><b>CPU Architecture</b></td>
</tr><tr>
<td><code>#LIBMICROHTTPD_LIBRARY_PATH_LINUX_ARM64</code></td>
<td>Linux ARM64</td>
</tr><tr>
<td><code>#LIBMICROHTTPD_LIBRARY_PATH_WINDOWS_X64</code></td>
<td>Windows x64</td>
</tr>
<table>

**If you are using Windows, you also need to make sure your executable has access to the `libmicrohttpd-dll.dll` file when launched by either including it in the `PATH` or in the same folder as the final executable !**


## Examples
A couple of examples are available in the *"Examples/"* folder:<br>
&nbsp;&nbsp;● [HelloBrowser](Examples/1_HelloBrowser.pb)

Please note that you may have to adjust the library path as desribed previously.


## License
This include is licensed under [TODO: Still figuring out how it will work with LGPL 2.1...](LICENSE)

The examples are released in the public domain.

The *libmicrohttpd* library is release under the LGPG 2.1


