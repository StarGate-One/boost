@echo off

set b2_job_prefix=%0-

setlocal

set boost_version=1_75_0

if not defined VS150COMNTOOLS (if not defined VS160COMNTOOLS ( goto usage))

if defined VS150COMNTOOLS (
   set b2_vs_toolset=vc141
   set b2_vs_toolset_nbr=14.1
   set b2_vs_version=2017
   set VS160COMNTOOLS=
   goto next
)

if defined VS160COMNTOOLS (
   set b2_vs_toolset=vc142
   set b2_vs_toolset_nbr=14.2
   set b2_vs_version=2019
   set VS150COMNTOOLS=
   goto next
)

goto usage

:next

if not exist D:\Git\boost\boost_vs%b2_vs_version%_%boost_version% (
   @echo D:\Git\boost\boost_vs%b2_vs_version%_%boost_version% does not exist
   @echo Please use script D:\Git\boost\boost-clone.cmd to create it
   @echo Exit now
   goto end
)

cd D:\Git\boost\boost_vs%b2_vs_version%_%boost_version%


if %Platform%==x64 (
   set b2_address_model=64
) else (
   set b2_address_model=32
)

set PreferredToolArchitecture=%Platform%
set VS140COMNTOOLS=

set BOOST_ROOT=.\
set BOOST_BUILD_PATH=%BOOST_ROOT%tools\build

@rem set LOCALAPPDATA=E:\
set TEMP=E:\Temp
set TMP=E:\Temp

set b2_MPI=N:
set b2_MSVC=R:
set b2_PYTHON=P:

@subst "%b2_MPI%" "D:\vcpkg_x64\vs%b2_vs_version%\prod\installed\%Platform%-windows"
@subst "%b2_MSVC%" "%VSINSTALLDIR%"
@subst "%b2_PYTHON%" "C:\Python\Python39"

@rem goto release

set MSMPI_BENCHMARKS=%b2_MPI%\Benchmarks\
set MSMPI_BIN=%b2_MPI%\Bin\
set MSMPI_INC=%b2_MPI_SDK%\Include\
set MSMPI_LIB32=%b2_MPI_SDK%\Lib\x86\
set MSMPI_LIB64=%b2_MPI_SDK%\Lib\x64\

set b2_bootstrap_log=.\bootstrap-vs%b2_vs_version%-%b2_vs_toolset%.log
set b2_build_log=%b2_job_prefix%build-vs%b2_vs_version%-%Platform%.log
@rem set b2_build_dir=.\build-vs%b2_vs_version%-%Platform%
set b2_build_dir=.\build
set b2_clean_log=%b2_job_prefix%clean-vs%b2_vs_version%-%Platform%.log
set b2_command=.\b2.exe
set b2_engine_dir=.\tools\build\src\engine
@rem set b2_stage_dir=.\stage-vs%b2_vs_version%-%Platform%
set b2_stage_dir=.\stage
set b2_user_config_jam=%BOOST_BUILD_PATH%\user-config.jam

set b2_other_sources=%b2_MPI%\include

@rem set b2_options_1=-a -j 8 -n -q -d 2
@rem 
set b2_options_1=-a -j 8 -q -d 2 
set b2_options_2=address-model=%b2_address_model% architecture=x86 debug-symbols=on link=static,shared
set b2_options_3=runtime-link=static,shared stage threading=single,multi toolset=msvc-%b2_vs_toolset_nbr%
set b2_options_4= variant=debug,release
set b2_options_5=--build-type=complete --layout=versioned --reconfigure
set b2_options_6=--build-dir=%b2_build_dir% --stagedir=%b2_stage_dir%
set b2_debug_options=--debug-building --debug-configuration --debug-generators

set b2_command_options=%b2_options_1% %b2_options_2% %b2_options_3% %b2_options_4% %b2_options_5% %b2_options_6% -sBZIP2_INCLUDE=%b2_other_sources% -sLZMA_INCLUDE=%b2_other_sources%\lzma -sZLIB_INCLUDE=%b2_other_sources% -sZSTD_INCLUDE=%b2_other_sources%
@rem set b2_command_options=%b2_command_options% %b2_debug_options%

set b2_clean=--clean-all

if exist %b2_bootstrap_log% del /f /q %b2_bootstrap_log%
if exist %b2_build_log% del /f /q %b2_build_log%
if exist %b2_clean_log% del /f /q %b2_clean_log%
if exist %b2_user_config_jam% del /f /q %b2_user_config_jam%

if exist %b2_command% del /f /q %b2_command%
if exist %b2_engine_dir%\b2.exe del /f /q %b2_engine_dir%\b2.exe 
if exist %b2_engine_dir%\bjam.exe del /f /q %b2_engine_dir%\bjam.exe 

@rem build user-config.jam file with our options
@echo: >%b2_user_config_jam%
@echo project user-config : ; >> %b2_user_config_jam%

@echo: >> %b2_user_config_jam%
@echo import toolset ; >>%b2_user_config_jam%

@rem add mpi
@rem echo: >> %b2_user_config_jam%
@rem echo using mpi : : >>%b2_user_config_jam%
@rem echo "<library-path>%b2_MPI%\\lib" >>%b2_user_config_jam%
@rem echo "<library-path>%b2_MPI%\\debug\\lib" >>%b2_user_config_jam%
@rem echo "<include>%b2_MPI%\\include" >>%b2_user_config_jam%
@rem echo "<find-shared-library>msmpi" >>%b2_user_config_jam%
@rem echo ; >>%b2_user_config_jam%

@rem add msvc
@echo: >> %b2_user_config_jam%
@echo using msvc >>%b2_user_config_jam%
@echo : %b2_vs_toolset_nbr%  >>%b2_user_config_jam%
@echo : "%b2_MSVC%\\VC\\Tools\\MSVC\\%VCToolsVersion%\\bin\\Host%Platform%\\%Platform%\\cl.exe" >>%b2_user_config_jam%

if %b2_vs_version%==2017 (
@echo : "/std:c++17 <cxxflags>/EHsc <compileflags>-Zm800 <compileflags>-nologo" >>%b2_user_config_jam%
)

if %b2_vs_version%==2019 (
@echo : "/std:c++17 <compileflags>-Zm800 <compileflags>-nologo" >>%b2_user_config_jam%
)

@echo ; >>%b2_user_config_jam%

@rem add python
@echo: >> %b2_user_config_jam%
@echo using python >>%b2_user_config_jam% 
@echo : 3.9 >>%b2_user_config_jam% 
@echo : "%b2_PYTHON%\\python.exe" >>%b2_user_config_jam%
@echo : "%b2_PYTHON%\\include" >>%b2_user_config_jam%
@echo : "%b2_PYTHON%\\libs" >>%b2_user_config_jam%
@echo : "<address-model>%b2_address_model%" >>%b2_user_config_jam%
@echo ; >>%b2_user_config_jam%
@echo: >> %b2_user_config_jam%

@rem add icu


@rem build b2.exe used to build boost libraries
@echo: >%b2_bootstrap_log%
@echo call .\bootstrap.bat %b2_vs_toolset% 
@echo call .\bootstrap.bat %b2_vs_toolset% >>%b2_bootstrap_log% 2>>&1
call .\bootstrap.bat %b2_vs_toolset% >>%b2_bootstrap_log% 2>>&1

@rem goto release

@echo:  >%b2_clean_log%  2>&1 
set    >>%b2_clean_log% 2>>&1 
@echo: >>%b2_clean_log% 2>>&1 

@rem clean old build of boost libraries
@echo:
@echo %b2_command% %b2_command_options% %b2_clean% 
@echo %b2_command% %b2_command_options% %b2_clean% >>%b2_clean_log% 2>>&1

%b2_command% %b2_command_options% %b2_clean% >>%b2_clean_log% 2>>&1

if exist %b2_build_dir% rmdir /q /s %b2_build_dir%
if exist %b2_stage_dir% rmdir /q /s %b2_stage_dir%

@rem goto release

@echo:  >%b2_build_log%  2>&1 
set    >>%b2_build_log% 2>>&1 
@echo: >>%b2_build_log% 2>>&1 

@rem build boost libraries
@echo:
@echo %b2_command% %b2_command_options%
@echo %b2_command% %b2_command_options% >>%b2_build_log% 2>>&1

%b2_command% %b2_command_options% >>%b2_build_log% 2>>&1

:release
@subst "%b2_MPI%" /D
@subst "%b2_MSVC%" /D
@subst "%b2_PYTHON%" /D
goto end
	
:usage
@@echo:
@@echo  Open Administrator: (x64 or x86) Native Tools Command Prompt for VS (2017 or 2019)
@@echo: Usage %0
@@echo  %0 only supports Visual Studio 2017 or 2019
@@echo:

:end		 
endlocal