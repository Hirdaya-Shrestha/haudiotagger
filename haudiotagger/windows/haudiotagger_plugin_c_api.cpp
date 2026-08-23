#include "include/haudiotagger/haudiotagger_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "haudiotagger_plugin.h"

void HaudiotaggerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  haudiotagger::HaudiotaggerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
