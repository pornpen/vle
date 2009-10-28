INCLUDE(InstallRequiredSystemLibraries)

IF (WIN32)
  SET(CPACK_GENERATOR "NSIS")
  SET(CPACK_SOURCE_GENERATOR "ZIP")
ENDIF (WIN32)

IF (UNIX)
  SET(CPACK_STRIP_FILES "bin/vle;bin/gvle;bin/eov;bin/oov;bin/vlemodeltest")
  SET(CPACK_GENERATOR "STGZ;TGZ;DEB;RPM")
  SET(CPACK_SOURCE_GENERATOR "ZIP;TGZ;TBZ2")
ENDIF (UNIX)

IF (APPLE)
  SET(CPACK_GENERATOR "OSXX11")
ENDIF (APPLE)

SET(CPACK_PACKAGE_NAME "VLE")
SET(CPACK_PACKAGE_VENDOR "VLE Development Team")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "VLE - Virtual Laboratory Environment")
SET(CPACK_PACKAGE_CONTACT "Gauthier Quesnel <quesnel@users.sourceforge.net>")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README")
SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/COPYING")
SET(CPACK_PACKAGE_FILE_NAME "${VLE_NAME_COMPLETE}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
SET(CPACK_PACKAGE_VERSION_MAJOR "${VLE_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${VLE_MINOR}")

IF ("${VLE_EXTRA}" STREQUAL "")
  SET(CPACK_PACKAGE_VERSION_PATCH "${VLE_PATCH}")
ELSE ("${VLE_EXTRA}" STREQUAL "")
  SET(CPACK_PACKAGE_VERSION_PATCH "${VLE_PATCH}${VLE_EXTRA}")
ENDIF ("${VLE_EXTRA}" STREQUAL "")

SET(CPACK_PACKAGE_INSTALL_DIRECTORY ${VLE_NAME_COMPLETE})
SET(CPACK_PACKAGE_EXECUTABLES "vle" "VLE" "oov" "OOV" "eov" "EOV" "gvle" "GVLE")

# CPack source configuration
SET(CPACK_SOURCE_PACKAGE_FILE_NAME ${VLE_NAME_COMPLETE})
SET(CPACK_SOURCE_IGNORE_FILES "\\\\.swp$;/\\\\.gitignore;/build/;/\\\\.git/")

# CPack DEB configuration
SET(CPACK_DEBIAN_PACKAGE_NAME ${VLE_NAME})
SET(CPACK_DEBIAN_PACKAGE_VERSION ${VLE_COMPLETE})
SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "")
SET(CPACK_DEBIAN_PACKAGE_BUILDS_DEPENDS "")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Gauthier Quesnel <quesnel@users.sourceforge.net>")
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "VLE, an environment of modelling and simulation")
SET(CPACK_DEBIAN_PACKAGE_SECTION "libs")
SET(CPACK_DEBIAN_PACKAGE_PRIORITY "extra")

# CPack RPM configuration
SET(CPACK_RPM_PACKAGE_SUMMARY "VLE, an environment of modelling and simulation")
SET(CPACK_RPM_PACKAGE_NAME ${VLE_NAME})
SET(CPACK_RPM_PACKAGE_VERSION ${VLE_MAJOR}.${VLE_MINOR}.${VLE_PATCH})
SET(CPACK_RPM_PACKAGE_ARCHITECTURE i386)
SET(CPACK_RPM_PACKAGE_RELEASE "1")
SET(CPACK_RPM_PACKAGE_VENDOR "VLE Development Team")
SET(CPACK_RPM_PACKAGE_LICENSE "GNU General Public License (GPL)")
SET(CPACK_RPM_PACKAGE_DESCRIPTION "VLE, an environment of modelling and simulation")

# CPack NSIS configuration
IF (CPACK_GENERATOR MATCHES "NSIS")
  SET(CMAKE_MODULE_PATH "share")
  SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/share)
  FILE(TO_CMAKE_PATH "${BOOST_INCLUDEDIR}" BOOST_INCLUDEDIR_NEW)
  FILE(TO_CMAKE_PATH "${BOOST_LIBRARYDIR}" BOOST_LIBRARYDIR_NEW)
  FILE(TO_CMAKE_PATH "${GTKMM_BASEPATH}" GTK_BASE)
  FILE(TO_CMAKE_PATH "${MINGW_BASEPATH}" MINGW_BASE)
  INSTALL(DIRECTORY "${BOOST_INCLUDEDIR_NEW}" DESTINATION include)
  INSTALL(DIRECTORY "${BOOST_LIBRARYDIR_NEW}/" DESTINATION bin FILES_MATCHING
    PATTERN "boost*.dll")
  INSTALL(DIRECTORY "${BOOST_LIBRARYDIR_NEW}/" DESTINATION lib FILES_MATCHING
    PATTERN "boost*.lib")

  INSTALL(FILES "${MINGW_BASE}/bin\\\\mingwm10.dll" DESTINATION bin)
  INSTALL(DIRECTORY "${BOOST_INCLUDEDIR_NEW}/boost" DESTINATION include)

  INSTALL(FILES "${GTK_BASE}/bin\\\\pkg-config.exe" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\gspawn-win32-helper-console.exe" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\gspawn-win32-helper.exe" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\charset.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\iconv.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\intl.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\jpeg62.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libatk-1.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libatkmm-1.6-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libcairo-2.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libcairomm-1.0-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgailutil-18.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgdk-win32-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgdkmm-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgdk_pixbuf-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgio-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgiomm-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libglade-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libglademm-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libglib-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libglibmm-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libglibmm_generate_extra_defs-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgmodule-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgobject-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgthread-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgtk-win32-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libgtkmm-2.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpango-1.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpangocairo-1.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpangoft2-1.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpangomm-1.4-1.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpangowin32-1.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libpng12-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libsigc-2.0-0.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libtiff3.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libxml++-2.6-2.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\libxml2.dll" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\pkg-config.exe" DESTINATION bin)
  INSTALL(FILES "${GTK_BASE}/bin\\\\zlib1.dll" DESTINATION bin)

  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\atk-1.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\atkmm-1.6" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\cairo" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\cairomm-1.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\gdkmm-2.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\giomm-2.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\glib-2.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\glibmm-2.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\gtk-2.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\gtkmm-2.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\libglade-2.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\libglademm-2.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\libxml" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\libxml++-2.6" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\pango-1.0" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\pangomm-1.4" DESTINATION include)
  INSTALL(DIRECTORY "${GTK_BASE}/include\\\\sigc++-2.0" DESTINATION include)

  INSTALL(FILES "${GTK_BASE}/include\\\\iconv.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\libcharset.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\libintl.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\localcharset.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\png.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\pngconf.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\tiff.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\tiffconf.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\tiffio.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\tiffvers.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\zconf.h" DESTINATION include)
  INSTALL(FILES "${GTK_BASE}/include\\\\zlib.h" DESTINATION include)

  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\gdkmm-2.4" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\giomm-2.4" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\glib-2.0" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\glibmm-2.4" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\gtk-2.0" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\gtkmm-2.4" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\libglademm-2.4" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\libxml++-2.6" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\pkgconfig" DESTINATION lib)
  INSTALL(DIRECTORY "${GTK_BASE}/lib\\\\sigc++-2.0" DESTINATION lib)

  INSTALL(FILES "${GTK_BASE}/lib\\\\libglib-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\atk-1.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\atk-1.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\cairo.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\cairo.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\charset.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gailutil.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gdk_pixbuf-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gdk-win32-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gio-2.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gio-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\glade-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\glib-2.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\glib-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gmodule-2.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gmodule-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gobject-2.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gobject-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gthread-2.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gthread-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\gtk-win32-2.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\iconv.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\intl.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\intl.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libatk-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libatkmm-1.6.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libcairo.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libcairomm-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgailutil.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgdk_pixbuf-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgdkmm-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgdk-win32-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgio-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgiomm-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libglade-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libglademm-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libglib-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libglibmm_generate_extra_defs-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libglibmm-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgmodule-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgobject-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgthread-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgtkmm-2.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libgtk-win32-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libiconv.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libintl.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpango-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpangocairo-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpangoft2-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpangomm-1.4.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpangowin32-1.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpng.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpng.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libpng12.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libsigc-2.0.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libtiff.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libtiff.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libtiff.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libxml++-2.6.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libxml2.dll.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libxml2.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\libz.a" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pango-1.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pango-1.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangocairo-1.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangocairo-1.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangoft2-1.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangoft2-1.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangowin32-1.0.def" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\pangowin32-1.0.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\zdll.lib" DESTINATION lib)
  INSTALL(FILES "${GTK_BASE}/lib\\\\zlib.def" DESTINATION lib)

  INSTALL(DIRECTORY "${GTK_BASE}/etc\\\\gtk-2.0" DESTINATION etc)
  INSTALL(DIRECTORY "${GTK_BASE}/etc\\\\pango" DESTINATION etc)

  INSTALL(DIRECTORY "${GTK_BASE}/share\\\\doc" DESTINATION share)
  INSTALL(DIRECTORY "${GTK_BASE}/share\\\\locale" DESTINATION share)
  INSTALL(DIRECTORY "${GTK_BASE}/share\\\\themes" DESTINATION share)

  SET(CPACK_NSIS_MUI_ICON "${PROJECT_SOURCE_DIR}/share/pixmaps\\\\vle.ico")
  SET(CPACK_NSIS_MUI_UNIICON "${PROJECT_SOURCE_DIR}/share/pixmaps\\\\vle.ico")
  SET(CPACK_PACKAGE_ICON "${PROJECT_SOURCE_DIR}/share/pixmaps\\\\logo.bmp")
  SET(CPACK_NSIS_MENU_LINKS "${VLE_SHARE_DIRS}/doc/vle.chm" "VLE API" "http://www.sourceforge.net/projects/vle" "VLE Web Site")
  SET(CPACK_CREATE_DESKTOP_LINKS gvle)
  SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\vle.exe")
  SET(CPACK_NSIS_DISPLAY_NAME "VLE - Virtual Laboratory Environment")
  SET(CPACK_NSIS_HELP_LINK "http://www.sourceforge.net/projects/vle")
  SET(CPACK_NSIS_URL_INFO_ABOUT "http://www.sourceforge.net/projects/vle")
  SET(CPACK_NSIS_CONTACT "Gauthier Quesnel <quesnel@users.sourceforge.net>")
  SET(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CPACK_PACKAGE_NAME} ${VLE_VERSION_SHORT}.0")
  SET(CPACK_NSIS_MODIFY_PATH ON)
ENDIF (CPACK_GENERATOR MATCHES "NSIS")

INCLUDE(CPack)

# vim:tw=0:ts=8:tw=0:sw=2:sts=2
