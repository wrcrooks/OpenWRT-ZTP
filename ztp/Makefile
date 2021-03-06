include $(TOPDIR)/rules.mk

PKG_NAME:=ztp
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

# PKG_BUILD_DIR:=$(BUILD_DIR)/ztp-$(PKG_VERSION)
# PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/wrcrooks/OpenWRT-ZTP.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=skip

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

DEFAULT_ZTP_SECRET:=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 33)

include $(INCLUDE_DIR)/package.mk

define Package/ztp
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Zero Touch Provisioning utility
	URL:=https://github.com/wrcrooks/OpenWRT-ZTP.git
	DEPENDS:= +curl +wget +jq +coreutils-tr
	MENU:=1
endef

define Package/ztp/description
 Zero Touch Provisioning utility
 Zero Touch Provisioning; a way to provision OpenWRT through only
 a WAN connection
endef

# define Package/ztp/config
# 	source "$(SOURCE)/Config.in"
# endef

CONFIG_ZTP_URL:=$(call qstrip,$(CONFIG_ZTP_URL))
CONFIG_ZTP_SECRET:=$(call qstrip,$(CONFIG_ZTP_SECRET))

# define Package/ztp/conffiles
# /etc/ztp.conf
# endef

# define Build/Configure
# 	$(call Build/Configure/Default)
# endef

define Build/Compile
	$(RM) -rf $(PKG_BUILD_DIR)/strpool
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/ztp \
		$(PKG_BUILD_DIR)/ztp.c
endef
# $(HOSTCC) $(PKG_BUILD_DIR)/ztp.c \
# 	-o $(PKG_BUILD_DIR)/ztp
# $(call Build/Compile/Default)
# $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/generate-ipv6-address.c -o $(PKG_BUILD_DIR)/generate-ipv6-address

define Package/ztp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ztp $(1)/usr/bin/
endef
# $(INSTALL_DIR) $(1)/etc/init.d/
# $(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
# $(INSTALL_DIR) $(1)/etc
# $(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/ztp.conf $(1)/etc/
# echo -e "$(CONFIG_ZTP_URL)" >> $(1)/etc/ztp.conf
# echo -e "\n$(CONFIG_ZTP_SECRET)" >> $(1)/etc/ztp.conf
# $(INSTALL_DIR) $(1)/etc/init.d
# $(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)

$(eval $(call BuildPackage,ztp))
