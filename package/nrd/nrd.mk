################################################################################
#
# NRD
#
################################################################################

NRD_VERSION = master
NRD_SITE = git@github.com:Metrological/nrd.git
NRD_SITE_METHOD = git
NRD_LICENSE = PROPRIETARY
NRD_DEPENDENCIES = freetype icu jpeg libpng libmng webp expat openssl c-ares libcurl
NRD_RUNTIMEDATA_LOCATION = /var/lib/netflix

ifeq ($(BR2_PACKAGE_DDPSTUB),y)
NRD_DEPENDENCIES += stubs
endif

NRD_INSTALL_STAGING = NO

ifeq ($(findstring y,$(BR2_PACKAGE_NRD_GRAPHICS_GLES2)$(BR2_PACKAGE_NRD_GRAPHICS_METROLOGICAL)),y)
NRD_DEPENDENCIES += $(call qstrip,$(BR2_PACKAGE_PROVIDES_OPENGL_ES))
endif

ifeq ($(BR2_PACKAGE_NRD_GRAPHICS_GLES2_EGL),y)
NRD_DEPENDENCIES += $(call qstrip,$(BR2_PACKAGE_PROVIDES_OPENGL_EGL))
endif

ifeq ($(BR2_PACKAGE_NRD_GRAPHICS_DIRECTFB),y)
NRD_CMAKE_FLAGS += -DGIBBON_GRAPHICS=directfb
NRD_DEPENDENCIES += alsa-lib portaudio webp ffmpeg tremor directfb
else ifeq ($(BR2_PACKAGE_NRD_GRAPHICS_GLES2),y)
NRD_CMAKE_FLAGS += -DGIBBON_GRAPHICS=gles2
else ifeq ($(BR2_PACKAGE_NRD_GRAPHICS_GLES2_EGL),y)
NRD_CMAKE_FLAGS += -DGIBBON_GRAPHICS=gles2-egl
else ifeq ($(BR2_PACKAGE_NRD_GRAPHICS_METROLOGICAL),y)
NRD_CMAKE_FLAGS += -DGIBBON_GRAPHICS=metrological-egl
else 
NRD_CMAKE_FLAGS += -DGIBBON_GRAPHICS=null
endif

ifeq ($(BR2_PACKAGE_NRD_NICE_THREADS),y)
NRD_CMAKE_FLAGS += -DGIBBON_NICE_THREADS=1
endif

ifeq ($(BR2_PACKAGE_NRD_PLAYER_SKELETON),y)
NRD_CMAKE_FLAGS += -DDPI_IMPLEMENTATION=skeleton
else ifeq ($(BR2_PACKAGE_NRD_PLAYER_X86),y)
NRD_CMAKE_FLAGS += -DDPI_IMPLEMENTATION=reference
else ifeq ($(BR2_PACKAGE_NRD_PLAYER_METROLOGICAL),y)
NRD_CMAKE_FLAGS += -DDPI_IMPLEMENTATION=metrological
endif

ifeq ($(BR2_PACKAGE_NRD_PLAYREADY),y)
NRD_CMAKE_FLAGS += -DDPI_REFERENCE_DRM=playready
else ifeq ($(BR2_PACKAGE_NRD_PLAYREADY2),y)
NRD_CMAKE_FLAGS += -DDPI_REFERENCE_DRM=playready2
else ifeq ($(BR2_PACKAGE_NRD_PLAYREADY25),y)
NRD_CMAKE_FLAGS += -DDPI_REFERENCE_DRM=playready2.5
else
NRD_CMAKE_FLAGS += -DDPI_REFERENCE_DRM=none
endif

ifeq ($(BR2_PACKAGE_NRD_INPUT_DEVINPUT),y)
NRD_CMAKE_FLAGS += -DGIBBON_INPUT=devinput
else ifeq ($(BR2_PACKAGE_NRD_INPUT_METROLOGICAL),y)
NRD_CMAKE_FLAGS += -DGIBBON_INPUT=metrological
else
NRD_CMAKE_FLAGS += -DGIBBON_INPUT=null
endif

ifeq ($(BR2_PACKAGE_NRD_APPLICATION),y)
NRD_CMAKE_FLAGS += -DGIBBON_MODE=executable
define NRD_TARGET_SET_DEFINITION
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/libJavaScriptCore.so $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/libWTF.so $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/netflix $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/manufss $(TARGET_DIR)/usr/bin
endef
else ifeq ($(BR2_PACKAGE_NRD_DYNAMICLIB),y)
NRD_RELOCATION_OPTION = -fPIC
NRD_INSTALL_STAGING = YES
NRD_CMAKE_FLAGS += -DGIBBON_MODE=shared
NRD_CMAKE_FLAGS += -DGIBBON_SCRIPT_JSC_DYNAMIC=0
define NRD_TARGET_SET_DEFINITION
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/libnetflix.so $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/manufss $(TARGET_DIR)/usr/bin
endef
define NRD_INSTALL_STAGING_CMDS
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/libnetflix.so $(STAGING_DIR)/usr/lib
        mkdir -p $(STAGING_DIR)/usr/include/nrd
        mkdir -p $(STAGING_DIR)/usr/include/nrd/nrd
        mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdbase
        mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdase
        mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdnet
        mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdapp
        mkdir -p $(STAGING_DIR)/usr/include/nrd/external
        cp -R $(@D)/output/include/nrdapp/config.h $(STAGING_DIR)/usr/include/nrd
	ln -s ./nrd/ $(STAGING_DIR)/usr/include/gibbon
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrd/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdbase/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdapp/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdnet/config.h
        cp -R $(@D)/netflix/nrdlib/src/base/*.h $(STAGING_DIR)/usr/include/nrd/nrdbase
        cp -R $(@D)/netflix/3rdparty/mongoose/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
        cp -R $(@D)/netflix/src/platform/gibbon/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
        cp -R $(@D)/netflix/src/nrdapp/Core/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
        cp -R $(@D)/netflix/nrdlib/src/nrd/Core/*.h $(STAGING_DIR)/usr/include/nrd/nrd
        cp -R $(@D)/netflix/nrdlib/src/nrd/NBP/*.h $(STAGING_DIR)/usr/include/nrd/nrd
        cp -R $(@D)/netflix/nrdlib/src/nrd/Dpi/*.h $(STAGING_DIR)/usr/include/nrd/nrd
        cp -R $(@D)/netflix/nrdlib/src/ase/common/*.h $(STAGING_DIR)/usr/include/nrd/nrdase
        cp -R $(@D)/netflix/nrdlib/src/net/util/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
        cp -R $(@D)/netflix/nrdlib/src/net/httplib/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
        cp -R $(@D)/netflix/nrdlib/src/net/websocket/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
        cp -R $(@D)/netflix/nrdlib/src/net/resourcemanager/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
        cp -R $(@D)/netflix/nrdlib/src/net/certstatus/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
        cp -R $(@D)/netflix/src/platform/gibbon/bridge/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
        cp -R $(@D)/partner/dpi/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
        cp -R $(@D)/partner/graphics/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
        cp -R $(@D)/partner/input/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
endef
else ifeq ($(BR2_PACKAGE_NRD_STATICLIB),y)
NRD_INSTALL_STAGING = YES
NRD_CMAKE_FLAGS += -DGIBBON_MODE=static
NRD_CMAKE_FLAGS += -DGIBBON_SCRIPT_JSC_DYNAMIC=0
define NRD_TARGET_SET_DEFINITION
	$(INSTALL) -m 755 $(@D)/output/src/platform/gibbon/manufss $(TARGET_DIR)/usr/bin
endef
define NRD_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/nrd
	mkdir -p $(STAGING_DIR)/usr/include/nrd/nrd
	mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdbase
	mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdase
	mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdnet
	mkdir -p $(STAGING_DIR)/usr/include/nrd/nrdapp
	mkdir -p $(STAGING_DIR)/usr/include/nrd/external
	cp -R $(@D)/output/include/nrdapp/config.h $(STAGING_DIR)/usr/include/nrd
	ln -s ./nrd $(STAGING_DIR)/usr/include/gibbon
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrd/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdbase/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdapp/config.h
	ln -s ../config.h $(STAGING_DIR)/usr/include/nrd/nrdnet/config.h
	cp -R $(@D)/netflix/nrdlib/src/base/*.h $(STAGING_DIR)/usr/include/nrd/nrdbase
	cp -R $(@D)/netflix/3rdparty/mongoose/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
	cp -R $(@D)/netflix/src/platform/gibbon/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
	cp -R $(@D)/netflix/src/nrdapp/Core/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
	cp -R $(@D)/netflix/nrdlib/src/nrd/Core/*.h $(STAGING_DIR)/usr/include/nrd/nrd
	cp -R $(@D)/netflix/nrdlib/src/nrd/NBP/*.h $(STAGING_DIR)/usr/include/nrd/nrd
	cp -R $(@D)/netflix/nrdlib/src/nrd/Dpi/*.h $(STAGING_DIR)/usr/include/nrd/nrd
	cp -R $(@D)/netflix/nrdlib/src/ase/common/*.h $(STAGING_DIR)/usr/include/nrd/nrdase
	cp -R $(@D)/netflix/nrdlib/src/net/util/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
	cp -R $(@D)/netflix/nrdlib/src/net/httplib/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
	cp -R $(@D)/netflix/nrdlib/src/net/websocket/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
	cp -R $(@D)/netflix/nrdlib/src/net/resourcemanager/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
	cp -R $(@D)/netflix/nrdlib/src/net/certstatus/*.h $(STAGING_DIR)/usr/include/nrd/nrdnet
	cp -R $(@D)/netflix/src/platform/gibbon/bridge/*.h $(STAGING_DIR)/usr/include/nrd/nrdapp
	cp -R $(@D)/partner/dpi/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
	cp -R $(@D)/partner/graphics/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
	cp -R $(@D)/partner/input/metrological/external/* $(STAGING_DIR)/usr/include/nrd/external
	cp -R $(TOPDIR)/package/nrd/files/netflix-biglib.mri $(@D)
	cd $(@D) && $(TARGET_CROSS)ar -M < $(@D)/netflix-biglib.mri
	cp -R $(@D)/libnetflix-biglib.a $(STAGING_DIR)/usr/lib
endef
endif

define NRD_INSTALL_TARGET_CMDS
	cp -R $(@D)/output/src/platform/gibbon/data $(TARGET_DIR)$(NRD_RUNTIMEDATA_LOCATION)
	$(SED) 's/<include>etc\//<include>\/var\/lib\/netflix\/etc\//g' $(TARGET_DIR)$(NRD_RUNTIMEDATA_LOCATION)/etc/conf/gibbon.xml
	$(SED) 's/<ui_cert>etc\//<ui_cert>\/var\/lib\/netflix\/etc\//g' $(TARGET_DIR)$(NRD_RUNTIMEDATA_LOCATION)/etc/conf/gibbon.xml
	$(NRD_TARGET_SET_DEFINITION)
endef

ifeq ($(BR2_PACKAGE_NRD_DEBUG_BUILD),y)
NRD_CMAKE_FLAGS += -DGIBBON_SCRIPT_JSC_DEBUG=1
NRD_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS_DEBUG="$(NRD_RELOCATION_OPTION) $(TARGET_CFLAGS)" -DCMAKE_CXX_FLAGS_DEBUG="$(NRD_RELOCATION_OPTION) $(TARGET_CXXFLAGS)"
else
NRD_CMAKE_FLAGS += -DGIBBON_SCRIPT_JSC_DEBUG=0
NRD_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$(NRD_RELOCATION_OPTION) $(TARGET_CFLAGS)" -DCMAKE_CXX_FLAGS_RELEASE="$(NRD_RELOCATION_OPTION) $(TARGET_CXXFLAGS)"
endif

NRD_CMAKE_FLAGS += -DGIBBON_PLATFORM=posix
NRD_CMAKE_FLAGS += -DBUILD_DPI_DIRECTORY=$(@D)/partner/dpi

NRD_CONFIGURE_CMDS = \
	mkdir $(@D)/output;	\
	cd $(@D)/output; \
	$(TARGET_MAKE_ENV) BUILDROOT_TOOL_PREFIX="$(GNU_TARGET_NAME)-" cmake -DCMAKE_SYSROOT=$(STAGING_DIR) $(@D)/netflix \
		-DCMAKE_TOOLCHAIN_FILE=$(HOST_DIR)/usr/share/buildroot/toolchainfile.cmake \
		$(NRD_CMAKE_FLAGS) \
		-DSMALL_FLAGS:STRING="-s -O3" -DSMALL_CFLAGS:STRING="" -DSMALL_CXXFLAGS:STRING="-fvisibility=hidden -fvisibility-inlines-hidden" -DNRDAPP_TOOLS="manufSSgenerator"

NRD_BUILD_CMDS = cd $(@D)/output ; $(TARGET_MAKE_ENV) make 

$(eval $(cmake-package))
