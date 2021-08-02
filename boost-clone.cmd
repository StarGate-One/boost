setlocal
D:
cd D:\Git\boost

set boost_version=1_75_0
set boost_release=1.75.0

set log_file=%0-%boost_version%.log

if exist .\boost_master_%boost_version% (
	rmdir /q /s .\boost_master_%boost_version%
)
@rem 
git clone -b boost-%boost_release% --single-branch --recursive git@github.com:boostorg/boost.git .\boost_master_%boost_version% >%log_file% 2>&1
@rem git clone --recursive git@github.com:boostorg/boost.git .\boost_master
cd .\boost_master_%boost_version%
git submodule update --init --recursive -v >>%log_file% 2>>&1
pause

cd ..
if exist .\boost_vs2017_%boost_version% (
	rmdir /q /s .\boost_vs2017_%boost_version%
)
git clone -b boost-%boost_release% --single-branch --recursive git@github.com:boostorg/boost.git .\boost_vs2017_%boost_version% >>%log_file% 2>>&1
cd .\boost_vs2017_%boost_version%
git submodule update --init --recursive -v >>%log_file% 2>>&1
copy /y ..\config_toolset.bat .\tools\build\src\engine >>%log_file% 2>>&1
copy /y ..\vswhere_usability_wrapper.cmd .\tools\build\src\engine >>%log_file% 2>>&1
pause

cd ..
if exist .\boost_vs2019_%boost_version% (
	rmdir /q /s .\boost_vs2019_%boost_version%
)
git clone -b boost-%boost_release% --single-branch --recursive git@github.com:boostorg/boost.git .\boost_vs2019_%boost_version% >>%log_file% 2>>&1
cd .\boost_vs2019_%boost_version%
git submodule update --init --recursive -v >>%log_file% 2>>&1
copy /y ..\config_toolset.bat .\tools\build\src\engine >>%log_file% 2>>&1
copy /y ..\vswhere_usability_wrapper.cmd .\tools\build\src\engine >>%log_file% 2>>&1
pause

endlocal
@rem git pull --recurse-submodules -v