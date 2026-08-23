//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <haudiotagger/haudiotagger_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) haudiotagger_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HaudiotaggerPlugin");
  haudiotagger_plugin_register_with_registrar(haudiotagger_registrar);
}
