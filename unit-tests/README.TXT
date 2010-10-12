This directory contains the automated test suite of the fbclient Lua package.

Firebird binaries were downloaded from the firebirdsql.org website.
Binary Lua modules were downloaded from their home websites where available,
or compiled using LuaRocks where not.


Windows 32bit platforms
-----------------------

Install the binaries:

	unzip win32.zip
	> cd win32
	win32> install_servers.bat

The installer will install multiple instances of Firebird server, one of each version
configured to listen on 127.0.0.1 port 3205, 3206, 3213, ... respectively, analogous
server's version number.

Run a test script:

	> run_test_file.bat test_all.lua

You can also run individual test files, eg:

	> run_test_file.bat test_binding.lua

When you're done testing:

	> cd win32
	win32> uninstall_servers.bat


Linux 32bit platforms
---------------------

	TODO
